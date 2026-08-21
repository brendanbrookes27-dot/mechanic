let isConnectedToVehicle = false;

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === "updateOdometer") {
        const odoHud = document.getElementById('odometer-hud');
        if (data.visible) {
            odoHud.classList.remove('hidden');
            document.getElementById('odo-val').innerText = data.mileage;
            document.getElementById('odo-unit').innerText = data.unit.toUpperCase();
        } else {
            odoHud.classList.add('hidden');
        }
    }

    if (data.action === "openTablet") {
        document.getElementById('tablet-container').classList.remove('hidden');
        if (data.vehicleData) {
            populateDiagnostics(data.vehicleData, data.vehicleModel);
        }
    }

    if (data.action === "updateVehicleData") {
        if (data.vehicleData) {
            populateDiagnostics(data.vehicleData);
        }
    }

    if (data.action === "closeTablet") {
        document.getElementById('tablet-container').classList.add('hidden');
        resetConnectionState();
    }

    if (data.action === "obdConnected") {
        isConnectedToVehicle = true;
        document.getElementById('connection-status').innerText = "Connected (OBD-II)";
        document.getElementById('connection-status').style.color = "#10b981";
        document.getElementById('connect-obd-btn').classList.add('hidden');
        document.getElementById('parts-health-container').classList.remove('hidden');
    }
});

function resetConnectionState() {
    isConnectedToVehicle = false;
    document.getElementById('connection-status').innerText = "Disconnected";
    document.getElementById('connection-status').style.color = "#ef4444";
    document.getElementById('connect-obd-btn').classList.remove('hidden');
    document.getElementById('parts-health-container').classList.add('hidden');
}

// Connect OBD Diagnostic Tool Button Click
document.getElementById('connect-obd-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/connectOBD`, { method: 'POST' });
});

// App Navigation
document.querySelectorAll('.app-icon').forEach(icon => {
    icon.addEventListener('click', function() {
        const appName = this.getAttribute('data-app');
        document.getElementById('home-screen').classList.add('hidden');
        document.getElementById(`app-${appName}`).classList.remove('hidden');
    });
});

document.querySelectorAll('.back-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.app-view').forEach(view => view.classList.add('hidden'));
        document.getElementById('home-screen').classList.remove('hidden');
    });
});

// Close Tablet Button
document.getElementById('close-tablet-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeTablet`, { method: 'POST' });
});

// Populate Diagnostics Data
function populateDiagnostics(data, vehicleModel) {
    if (data.plate) document.getElementById('diag-plate').innerText = data.plate;
    if (vehicleModel) document.getElementById('diag-model').innerText = vehicleModel;
    if (data.mileage !== undefined) document.getElementById('diag-mileage').innerText = (data.mileage || 0.0).toFixed(1);

    const parts = ['oil', 'spark_plugs', 'clutch', 'suspension', 'brakes', 'tires', 'fuel_filter'];
    parts.forEach(part => {
        if (data[part] !== undefined) {
            const val = Math.floor(data[part]);
            const bar = document.getElementById(`bar-${part}`);
            const label = document.getElementById(`val-${part}`);
            if (bar && label) {
                bar.style.width = `${val}%`;
                label.innerText = `${val}%`;
                bar.style.background = val < 25 ? '#ef4444' : (val < 50 ? '#f59e0b' : '#10b981');
            }
        }
    });
}

// Repair Buttons
document.querySelectorAll('.repair-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        if (!isConnectedToVehicle) return;
        const part = this.getAttribute('data-part');
        const plate = document.getElementById('diag-plate').innerText;
        fetch(`https://${GetParentResourceName()}/repairPart`, {
            method: 'POST',
            body: JSON.stringify({ plate: plate, part: part })
        });
    });
});

// Buy Mod Buttons
document.querySelectorAll('.buy-mod-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        const category = this.getAttribute('data-category');
        const mod = this.getAttribute('data-mod');
        const cost = this.getAttribute('data-cost');
        fetch(`https://${GetParentResourceName()}/buyTuningMod`, {
            method: 'POST',
            body: JSON.stringify({ category: category, mod: mod, cost: parseInt(cost) })
        });
    });
});

// Buy Part Items (Parts Shop)
document.querySelectorAll('.buy-part-item').forEach(btn => {
    btn.addEventListener('click', function() {
        const item = this.getAttribute('data-item');
        const cost = this.getAttribute('data-cost');
        fetch(`https://${GetParentResourceName()}/buyShopItem`, {
            method: 'POST',
            body: JSON.stringify({ item: item, cost: parseInt(cost) })
        });
    });
});

// Invoicing
document.getElementById('send-invoice-btn').addEventListener('click', function() {
    const target = document.getElementById('invoice-target').value;
    const amount = document.getElementById('invoice-amount').value;
    const reason = document.getElementById('invoice-reason').value;

    fetch(`https://${GetParentResourceName()}/sendInvoice`, {
        method: 'POST',
        body: JSON.stringify({ target: target, amount: amount, reason: reason })
    });
});

// Close on Escape Key
window.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeTablet`, { method: 'POST' });
    }
});
