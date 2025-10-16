#!/usr/bin/env python3
# SPDX-License-Identifier: MIT

# Copyright David Kristiansen

import argparse
import logging
import sys
import signal
import json
import os
import subprocess
import threading
import time
from typing import Dict, Any

logger = logging.getLogger(__name__)


def signal_handler(sig, frame):
    logger.info("Received signal to stop, exiting")
    sys.stdout.write("\n")
    sys.stdout.flush()
    sys.exit(0)


class PlayerManager:
    def __init__(self, selected_player=None, excluded_player=[]):
        self.selected_player = selected_player
        self.excluded_player = excluded_player.split(",") if excluded_player else []
        self.players: Dict[str, Dict[str, Any]] = {}
        self.lock = threading.Lock()

        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)

    def run(self):
        logger.info("Starting playerctl listener")

        cleanup_thread = threading.Thread(target=self.cleanup_vanished_players, daemon=True)
        cleanup_thread.start()

        command = [
            "playerctl",
            "--follow",
            "-f",
            "{playerName}\t{status}\t{mpris:trackid}\t{artist}\t{title}",
            "status",
            "metadata",
        ]
        try:
            self.process = subprocess.Popen(command, stdout=subprocess.PIPE, text=True, encoding="utf-8")
        except FileNotFoundError:
            logger.error("playerctl not found. Please install it.")
            sys.exit(1)

        for line in iter(self.process.stdout.readline, ""):
            self.process_player_update(line.strip())

        logger.info("playerctl process finished.")

    def cleanup_vanished_players(self):
        while True:
            time.sleep(5)
            try:
                result = subprocess.run(["playerctl", "--list-all"], capture_output=True, text=True, check=False)
                if result.returncode != 0 or not result.stdout.strip():
                    current_players = []
                else:
                    current_players = result.stdout.strip().split("\n")
            except FileNotFoundError:
                logger.error("playerctl not found during cleanup.")
                break  # Stop the thread

            should_update = False
            with self.lock:
                vanished_players = set(self.players.keys()) - set(current_players)
                if vanished_players:
                    logger.info(f"Vanished players detected: {vanished_players}")
                    for player in vanished_players:
                        if player in self.players:
                            del self.players[player]
                    should_update = True

            if not current_players and self.players:
                with self.lock:
                    self.players.clear()
                    should_update = True

            if should_update:
                self.update_display()

    def process_player_update(self, line: str):
        logger.debug(f"Received update: {line}")
        try:
            name, status, track_id, artist, title = line.split("\t", 4)
        except ValueError:
            logger.warning(f"Could not parse player update: {line}")
            return

        if (self.selected_player and name != self.selected_player) or (name in self.excluded_player):
            return

        with self.lock:
            self.players[name] = {
                "status": status,
                "track_id": track_id,
                "artist": artist,
                "title": title,
            }

        self.update_display()

    def update_display(self):
        with self.lock:
            players_copy = dict(self.players)

        if not players_copy:
            self.clear_output()
            return

        playing_players = []
        paused_players = []
        other_players = []

        for name, data in players_copy.items():
            if data['status'] == 'Playing':
                playing_players.append((name, data))
            elif data['status'] == 'Paused':
                paused_players.append((name, data))
            else:
                other_players.append((name, data))

        player_to_show = None
        player_name_to_show = None

        if playing_players:
            player_name_to_show, player_to_show = playing_players[-1]
        elif paused_players:
            player_name_to_show, player_to_show = paused_players[-1]
        elif other_players:
            player_name_to_show, player_to_show = other_players[-1]

        if not player_to_show:
            self.clear_output()
            return

        artist = player_to_show.get("artist", "")
        title = player_to_show.get("title", "").replace("&", "&amp;")
        track_id = player_to_show.get("track_id", "")

        track_info = ""
        if player_name_to_show == "spotify" and ":ad:" in track_id:
            track_info = "Advertisement"
        elif artist and title:
            track_info = f"{artist} - {title}"
        else:
            track_info = title

        if track_info:
            status = player_to_show["status"]
            if status == "Playing":
                icon = ""
            elif status == "Paused":
                icon = ""
            else:
                icon = ""
            track_info = f"{icon} {track_info}"

        self.write_output(track_info, player_name_to_show, player_to_show["status"])

    def write_output(self, text: str, player_name: str, status: str):
        logger.debug(f"Writing output: {text}")
        output = {"text": text, "class": f"custom-{player_name}", "alt": status}
        sys.stdout.write(json.dumps(output) + "\n")
        sys.stdout.flush()

    def clear_output(self):
        sys.stdout.write("\n")
        sys.stdout.flush()


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose", action="count", default=0)
    parser.add_argument("-x", "--exclude", help="Comma-separated list of excluded player names")
    parser.add_argument("--player", help="Player name to filter for")
    parser.add_argument("--enable-logging", action="store_true")
    return parser.parse_args()


def main():
    arguments = parse_arguments()

    if arguments.enable_logging:
        logfile = os.path.join(os.path.dirname(os.path.realpath(__file__)), "media-player.log")
        logging.basicConfig(
            filename=logfile, level=logging.DEBUG, format="%(asctime)s %(name)s %(levelname)s:%(lineno)d %(message)s"
        )

    logger.setLevel(max((3 - arguments.verbose) * 10, 0))

    logger.info("Creating player manager")
    if arguments.player:
        logger.info(f"Filtering for player: {arguments.player}")
    if arguments.exclude:
        logger.info(f"Exclude player(s): {arguments.exclude}")

    manager = PlayerManager(arguments.player, arguments.exclude)
    manager.run()


if __name__ == "__main__":
    main()
