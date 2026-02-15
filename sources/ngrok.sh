#!/usr/bin/env bash
home-manager switch
systemctl --user daemon-reload
systemctl --user enable --now ngrok
systemctl --user status ngrok
journalctl --user -u ngrok -f

