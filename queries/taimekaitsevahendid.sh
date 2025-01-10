#!/bin/bash

curl -X POST "https://andmed.stat.ee/api/v1/et/stat/KK208" \
-H "Content-Type: application/json" \
-d '{
  "query": [
    {
      "code": "Taimekaitsevahend",
      "selection": {
        "filter": "item",
        "values": [
          "1",
          "2",
          "3",
          "4",
          "5",
          "6",
          "7",
          "8"
        ]
      }
    }
  ],
  "response": {
    "format": "csv"
  }
}'
