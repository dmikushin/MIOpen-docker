#!/bin/bash
COMMIT=b7e1f6bc
sed "s/##COMMIT##/${COMMIT}/g" git_checkout.sh.in >git_checkout.sh
docker build -t rocm/miopen:${COMMIT} .

