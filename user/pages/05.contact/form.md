---
title: Contact
form:
    name: contact-form
    fields:
        -
            name: name
            label: Name
            placeholder: 'Your full name'
            type: text
            validate:
                required: true
        -
            name: email
            label: Email
            placeholder: 'Your email address'
            type: email
            validate:
                required: true
        -
            name: message
            label: Message
            type: textarea
            validate:
                required: true
    buttons:
        -
            type: submit
            value: Send
    process:
        -
            email:
                from: '{{ config.plugins.email.from }}'
                to: '{{ config.plugins.email.to }}'
                subject: '[Contact Form] Message from {{ form.value.name|e }}'
                body: '{% include ''forms/data.html.twig'' %}'
        -
            save:
                fileprefix: contact-
                dateformat: Ymd-His-u
                extension: txt
                body: '{% include ''forms/data.html.twig'' %}'
        -
            message: 'Thank you for your message!'
        -
            display: true
project_media: {  }
intro: 'sqssqs'
---

# Contact Us

Feel free to send us a message using the form below.
