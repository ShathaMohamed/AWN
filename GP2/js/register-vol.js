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

// تعريف حقل الهوية وإضافة مستمع حدث
const identityInput = document.getElementById('identityNumber');

identityInput.addEventListener('input', function(e) {
    // إزالة أي حرف غير رقمي
    let value = e.target.value.replace(/\D/g, '');
    
    // اقتصار الطول على 10 أرقام
    value = value.substring(0, 10);
    
    // تحديث قيمة الحقل
    e.target.value = value;
});

// Form validation
document.getElementById('volunteerForm').addEventListener('submit', function(e) {
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
        
        if (input.id === 'identityNumber' && !input.value.match(input.pattern)) {
            input.style.borderColor = '#dc3545';
            isValid = false;
        }
    });

    if (isValid) {
        console.log('Form submitted successfully');
        // Add form submission logic here
    }
});
