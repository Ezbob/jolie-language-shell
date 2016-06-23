#!/bin/bash

# start all services in one window
( cd dockerService; jolie docker_jolie.ol) & ( cd frontend; jolie eval_frontend.ol) &
