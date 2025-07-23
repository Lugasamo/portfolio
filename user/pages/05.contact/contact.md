---
title: Contact
form:
    name: contact-form
    classes: contact-form
    fields:
        name:
            label: Name
            placeholder: 'Your full name'
            type: text
            validate:
                required: true
                message: 'Please enter your name'
        email:
            label: Email
            placeholder: your@email.com
            type: email
            validate:
                required: true
                rule: email
                message: 'Please enter a valid email'
        subject:
            label: Subject
            placeholder: 'How can we help you?'
            type: text
            validate:
                required: true
                message: 'Please enter a subject'
        message:
            label: Message
            placeholder: 'Write your message here...'
            type: textarea
            validate:
                required: true
                message: 'Please write your message'
    buttons:
        submit:
            type: submit
            value: 'Send Message'
    process:
        -
            email:
                from: '{{ form.value.email }}'
                from_name: '{{ form.value.name }}'
                to: di.luisgabriel@gmail.com
                to_name: 'Saavedral Site'
                subject: 'Message from Saavedral.au {{ form.value.subject }}'
                body: '{% include ''forms/data.html.twig'' %}'
        -
            message: 'Thank you for your message! We''ll get back to you soon.'
        -
            reset: true
profile:
    name: 'UX/UI & UI Developer / Digital Product Design'
    bio: 'I specialize in driving the creation of intuitive, high-performing digital products across diverse platforms, leveraging expertise in UX, UI, and front-end development. Based in Melbourne, I focus on e-commerce CRO and robust design systems.'
    image: luis-saavedra-profile.png
    columnl:
        skills: "Experience Design</br>\nUser Interface Design</br>\nProduct Design</br>"
    columnr:
        skills: "Web Design</br>\nAccessibility</br>\nVisual Strategy</br>"
columnl:
    skills: "Experience Design</br>\nUser Interface Design</br>\nProduct Design</br>"
columnr:
    skills: "Web Design</br>\nAccessibility</br>\nVisual Strategy</br>"
project_media: {  }
---

# Contact Us
<br>
### Please fill out the form below and we'll get back to you as soon as possible.