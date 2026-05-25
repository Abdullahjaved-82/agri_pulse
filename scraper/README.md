# Scraper Scheduler

This folder contains the price scrapers and a simple daily scheduler that writes results to Firestore.

## Requirements

- Python 3.10+
- `playwright` and `firebase-admin`
- A Firebase service account JSON

The scrapers use a service account file to write into Firestore. Place it in this folder and either:

- Name it `serviceAccountKey.json`, or
- Set `FIREBASE_SERVICE_ACCOUNT` to the full path.

## Install

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python -m playwright install
```

## Run once

```powershell
python amis_scraper.py
python market_scraper.py
```

## Run daily scheduler

```powershell
$env:FIREBASE_SERVICE_ACCOUNT = "D:\AGRI_PULSE\scraper\serviceAccountKey.json"
$env:DAILY_SCRAPE_TIME = "02:00"
$env:RUN_ON_START = "true"
python daily_scheduler.py
```

## Notes

- The AMIS and market scrapers currently simulate prices when real pages fail to parse.
- The daily scheduler writes:
  - Government prices to `crops` and `crops/{crop}/history`.
  - Open market prices to `market_prices` and `market_prices/{crop}/history`.

