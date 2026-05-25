import asyncio
import datetime
import logging
import os
import time

from amis_scraper import scrape_punjab_amis
from market_scraper import scrape_local_markets

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def _parse_time(value: str) -> tuple[int, int]:
    try:
        parts = value.strip().split(":")
        if len(parts) != 2:
            raise ValueError
        return int(parts[0]), int(parts[1])
    except Exception:
        return 2, 0


def _seconds_until(hour: int, minute: int) -> float:
    now = datetime.datetime.now()
    target = now.replace(hour=hour, minute=minute, second=0, microsecond=0)
    if target <= now:
        target += datetime.timedelta(days=1)
    return (target - now).total_seconds()


async def _run_scrapers() -> None:
    logger.info("Running scheduled scrapers...")
    await scrape_punjab_amis()
    await scrape_local_markets()
    logger.info("Scrapers completed.")


def run_once() -> None:
    asyncio.run(_run_scrapers())


def main() -> None:
    run_on_start = os.getenv("RUN_ON_START", "true").lower() == "true"
    hour, minute = _parse_time(os.getenv("DAILY_SCRAPE_TIME", "02:00"))

    if run_on_start:
        run_once()

    while True:
        seconds = _seconds_until(hour, minute)
        logger.info("Next scrape in %s seconds", int(seconds))
        time.sleep(seconds)
        run_once()


if __name__ == "__main__":
    main()

