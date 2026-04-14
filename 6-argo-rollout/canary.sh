#!/bin/bash

INGRESS_IP="172.17.18.230"
CANARY_COUNT=0
STABLE_COUNT=0

echo "Testing 50/50 traffic split..."
echo "Canary: nasirnjs/kinder-frontend:12"
echo "Stable: nasirnjs/kinder-frontend:18"
echo ""

for i in {1..30}; do
  RESPONSE=$(curl -s -H "Host: nasirtechtalks.com" http://$INGRESS_IP/)
  
  if [[ $RESPONSE == *":12"* ]] || [[ $RESPONSE == *"canary"* ]]; then
    echo "✓ Request $i: CANARY (v12)"
    ((CANARY_COUNT++))
  else
    echo "• Request $i: STABLE (v18)"
    ((STABLE_COUNT++))
  fi
  
  echo "Current - Stable: $STABLE_COUNT, Canary: $CANARY_COUNT ($((CANARY_COUNT * 100 / (STABLE_COUNT + CANARY_COUNT)))%)"
  echo "---"
  sleep 1
done

echo ""
echo "Final Results:"
echo "Stable (v18): $STABLE_COUNT"
echo "Canary (v12): $CANARY_COUNT"
echo "Canary Percentage: $((CANARY_COUNT * 100 / (STABLE_COUNT + CANARY_COUNT)))%"