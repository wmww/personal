#!/bin/bash
$(sleep 0.5; busctl call --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 SetVisible b true) & squeekboard
