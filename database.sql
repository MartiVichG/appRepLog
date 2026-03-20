CREATE DATABASE IF NOT EXISTS gym_app;
USE gym_app;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL
);

-- Puesto que el proyecto está en sus inicios y vamos a cambiar la estructura pivotal de la app, 
-- reiniciamos las tablas para poder ligar los entrenamientos a un usuario de ahora en adelante.
DROP TABLE IF EXISTS exercise_sets;
DROP TABLE IF EXISTS workouts;

CREATE TABLE workouts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE exercise_sets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    workout_id INT NOT NULL,
    exercise_name VARCHAR(100) NOT NULL,
    weight DECIMAL(5,2) NOT NULL,
    reps INT NOT NULL,
    FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE
);
