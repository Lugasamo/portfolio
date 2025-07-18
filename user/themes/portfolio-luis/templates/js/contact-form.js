/**
 * Contact Form Handler
 * Advanced spam protection and user experience enhancements
 */

class ContactForm {
    constructor() {
        this.form = document.getElementById('contact-form');
        this.submitBtn = document.getElementById('submit-btn');
        this.submitText = document.getElementById('submit-text');
        this.submitLoading = document.getElementById('submit-loading');
        this.startTime = Date.now();
        this.isSubmitting = false;
        
        // Rate limiting
        this.maxSubmissions = 3;
        this.timeWindow = 3600000; // 1 hour in milliseconds
        
        this.init();
    }

    init() {
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.setup());
        } else {
            this.setup();
        }
    }

    setup() {
        if (!this.form) return;
        
        this.setupFormTimestamp();
        this.setupValidation();
        this.setupSubmitHandler();
        this.setupRateLimiting();
        this.setupFieldEnhancements();
        this.setupKeyboardShortcuts();
    }

    setupFormTimestamp() {
        // Set form start time for time-based validation
        const formTimeField = document.getElementById('form_time');
        if (formTimeField) {
            formTimeField.value = this.startTime.toString();
        }
    }

    setupValidation() {
        // Real-time validation
        const fields = this.form.querySelectorAll('input, textarea, select');
        fields.forEach(field => {
            field.addEventListener('blur', () => this.validateField(field));
            field.addEventListener('input', () => this.clearFieldError(field));
        });

        //