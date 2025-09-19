# 🎨 Pixel Positions – Laravel Final Project (Laracasts "Laravel in 30 Days")

A portfolio-ready web application built while following Jeffrey Way’s [Laravel in 30 Days](https://www.youtube.com/watch?v=SqTdHCTWqks) series.  
This project demonstrates **modern Laravel 12 practices** including authentication, Blade templates, MVC structure, validation, and database migrations.

---

## 📌 Problem & Goal
The goal was to practice building a real-world Laravel application from scratch:
- Learn to work with Laravel’s routing, controllers, and Eloquent ORM.
- Build reusable Blade components and layouts.
- Implement CSRF protection and validation on forms.
- Deploy a project-ready Laravel app suitable for a portfolio.

---

## 🛠️ Tech Stack
- **Backend:** Laravel 12 (PHP 8+)
- **Frontend:** Blade Templates, TailwindCSS (or Bootstrap if used)
- **Database:** MySQL (via Eloquent ORM)
- **Tooling:** Composer, NPM, GitHub

---

## ✨ Features
- User authentication (login, register, logout)
- CRUD functionality (create, edit, delete posts or equivalent)
- Form validation & CSRF protection
- Responsive layout for desktop and mobile
- Basic error handling & flash messaging

---

## 🚀 Getting Started
### Prerequisites
- PHP 8.1+  
- Composer  
- MySQL or SQLite  
- Node.js & NPM  

### Installation
```bash
git clone https://github.com/dvkak1/pixel-positions-laracasts-course-final-project.git
cd pixel-positions-laracasts-course-final-project
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
npm install && npm run dev
php artisan serve
