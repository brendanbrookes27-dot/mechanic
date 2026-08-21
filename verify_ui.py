import os
from playwright.sync_api import sync_playwright

def run_verification(page):
    abs_path = os.path.abspath("web/index.html")
    page.goto(f"file://{abs_path}")
    page.wait_for_timeout(500)

    # Trigger Odometer HUD and Tablet UI with vehicleModel and obdConnected
    page.evaluate("""
        window.postMessage({
            action: 'updateOdometer',
            visible: true,
            mileage: '124.5',
            unit: 'mi'
        }, '*');
        window.postMessage({
            action: 'openTablet',
            vehicleData: {
                plate: 'LS 888',
                mileage: 124.5,
                oil: 85,
                spark_plugs: 90,
                clutch: 95,
                suspension: 100,
                brakes: 70,
                tires: 80,
                fuel_filter: 90
            },
            vehicleModel: 'Elegy RH8'
        }, '*');
        window.postMessage({
            action: 'obdConnected'
        }, '*');
    """)

    page.wait_for_timeout(1000)
    page.screenshot(path="/home/jules/verification/screenshots/tablet_preview_connected.png")

if __name__ == "__main__":
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            record_video_dir="/home/jules/verification/videos"
        )
        page = context.new_page()
        try:
            run_verification(page)
        finally:
            context.close()
            browser.close()
