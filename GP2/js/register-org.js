let map;
let marker;
let locationInput = document.getElementById('location');
let mapContainer = document.querySelector('.map-container');

function openMap() {
    mapContainer.style.display = 'flex';
    if (!map) {
        initMap();
    }
}

function closeMap() {
    mapContainer.style.display = 'none';
}

function confirmLocation() {
    if (marker) {
        const latlng = marker.getLatLng();
        locationInput.value = `${latlng.lat.toFixed(6)}, ${latlng.lng.toFixed(6)}`;
    }
    closeMap();
}

function initMap() {
    map = L.map('map').setView([24.7136, 46.6753], 6);
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    map.on('click', function(e) {
        if (marker) {
            map.removeLayer(marker);
        }
        marker = L.marker(e.latlng).addTo(map);
    });
}

// Phone input formatting
const phoneInput = document.querySelector('.phone-input');

phoneInput.addEventListener('input', function(e) {
    let value = e.target.value.replace(/\D/g, '');
    
    if (value.length > 0 && value[0] !== '5') {
        value = '5' + value.substring(1);
    }
    
    value = value.substring(0, 9);
    e.target.value = value;
});

// Form validation
document.getElementById('organizationForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const inputs = this.querySelectorAll('input[required], select[required]');
    let isValid = true;

    inputs.forEach(input => {
        if (!input.value) {
            input.style.borderColor = '#dc3545';
            isValid = false;
        } else {
            input.style.borderColor = '#dee2e6';
        }

        if (input.type === 'tel' && !input.value.match(input.pattern)) {
            input.style.borderColor = '#dc3545';
            isValid = false;
        }
    });

    if (isValid) {
        console.log('Form submitted successfully');
        // Add form submission logic here
    }
});
