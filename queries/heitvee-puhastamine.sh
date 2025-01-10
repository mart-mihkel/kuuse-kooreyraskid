#!/bin/bash

curl -X POST "https://andmed.stat.ee/api/v1/et/stat/KK23" \
-H "Content-Type: application/json" \
-d '{
  "query": [
    {
      "code": "Maakond",
      "selection": {
        "filter": "item",
        "values": [
          "00",
          "37",
          "39",
          "44",
          "49",
          "51",
          "57",
          "59",
          "65",
          "67",
          "70",
          "74",
          "78",
          "82",
          "84",
          "86"
        ]
      }
    }
  ],
  "response": {
    "format": "csv"
  }
}'
