DROP TABLE IF EXISTS Denuncias;
DROP TABLE IF EXISTS Reseñas;
DROP TABLE IF EXISTS Descargas;
DROP TABLE IF EXISTS Apuntes;
DROP TABLE IF EXISTS Asignaturas;
DROP TABLE IF EXISTS Cursos;
DROP TABLE IF EXISTS Moderadores;
DROP TABLE IF EXISTS Administradores;
DROP TABLE IF EXISTS Usuarios;
DROP TABLE IF EXISTS Cuentas;

CREATE TABLE Cuentas(
	cuentaId INT PRIMARY KEY AUTO_INCREMENT,
	email VARCHAR(255) UNIQUE NOT NULL,
	nombre VARCHAR(255) NOT NULL,
	contraseña VARCHAR(255) NOT NULL
);

CREATE TABLE Usuarios(
	cuentaId INT PRIMARY KEY,
	FOREIGN KEY (cuentaId) REFERENCES Cuentas(cuentaId)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE Administradores(
	cuentaId INT PRIMARY KEY,
	FOREIGN KEY (cuentaId) REFERENCES Cuentas(cuentaId)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE Moderadores(
	cuentaId INT PRIMARY KEY,
	fechaNombramiento DATE NOT NULL,
	FOREIGN KEY (cuentaId) REFERENCES Usuarios(cuentaId)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE Cursos(
	cursoId INT PRIMARY KEY AUTO_INCREMENT,
	nombre VARCHAR(255) UNIQUE NOT NULL,
	CONSTRAINT CursoVálido CHECK (nombre IN ('PRIMERO','SEGUNDO','TERCERO','CUARTO'))
);

CREATE TABLE Asignaturas(
	asignaturaId INT PRIMARY KEY AUTO_INCREMENT,
	cursoId INT NOT NULL,
	código VARCHAR(7) UNIQUE NOT NULL,
	nombre VARCHAR(255) NOT NULL,
	créditos INT NOT NULL,
	FOREIGN KEY (cursoId) REFERENCES Cursos(cursoId)
		ON DELETE RESTRICT
		ON UPDATE RESTRICT,
	CONSTRAINT CréditosPositivos CHECK (créditos>0)
);

CREATE TABLE Apuntes(
	apunteId INT PRIMARY KEY AUTO_INCREMENT,
	asignaturaId INT NOT NULL,
	autorId INT NOT NULL,
	título VARCHAR(255) NOT NULL,
	descripción VARCHAR(255) NOT NULL,
	fechaSubida DATE NOT NULL,
	archivo VARCHAR(255) NOT NULL,
	añoAcadémico VARCHAR(7) NOT NULL,
	tipo VARCHAR(255) NOT NULL,
	FOREIGN KEY (asignaturaId) REFERENCES Asignaturas(asignaturaId)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY (autorId) REFERENCES Usuarios(cuentaId)
		ON DELETE RESTRICT
		ON UPDATE RESTRICT,
	CONSTRAINT FormatoAñoAcadémico CHECK (añoAcadémico LIKE '____/__'),
	CONSTRAINT TipoVálidoApunte CHECK (tipo IN ('TEORÍA','EJERCICIOS','PRÁCTICAS','EXÁMENES','TRABAJOS'))
);

CREATE TABLE Descargas(
	descargaId INT PRIMARY KEY AUTO_INCREMENT,
	descargadorId INT NOT NULL,
	apunteId INT NOT NULL,
	fecha DATE NOT NULL,
	UNIQUE (descargadorId, apunteId),
	FOREIGN KEY (descargadorId) REFERENCES Usuarios(cuentaId)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY (apunteId) REFERENCES Apuntes(apunteId)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE Reseñas(
	reseñaId INT PRIMARY KEY AUTO_INCREMENT,
	apunteId INT NOT NULL,
	usuarioId INT NOT NULL,
	puntuación INT NOT NULL,
	comentario VARCHAR(500),
	fecha DATE NOT NULL,
	UNIQUE (usuarioId, apunteId),
	FOREIGN KEY (apunteId) REFERENCES Apuntes(apunteId)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY (usuarioId) REFERENCES Usuarios(cuentaId)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT RI03_PuntuaciónEntre1y5 CHECK (puntuación BETWEEN 1 AND 5)
);

CREATE TABLE Denuncias(
	denunciaId INT PRIMARY KEY AUTO_INCREMENT,
	apunteId INT NOT NULL,
	usuarioId INT NOT NULL,
	moderadorId INT,
	motivo VARCHAR(500) NOT NULL,
	fecha DATE NOT NULL,
	estado VARCHAR(11) NOT NULL DEFAULT 'PENDIENTE',
	UNIQUE (usuarioId, apunteId),
	FOREIGN KEY (apunteId) REFERENCES Apuntes(apunteId)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY (usuarioId) REFERENCES Usuarios(cuentaId)
		ON DELETE RESTRICT
		ON UPDATE RESTRICT,
	FOREIGN KEY (moderadorId) REFERENCES Moderadores(cuentaId)
		ON DELETE RESTRICT
		ON UPDATE RESTRICT,
	CONSTRAINT EstadoDenunciaVálido CHECK (estado IN ('PENDIENTE','ACEPTADA','RECHAZADA')),
	CONSTRAINT RI04_ModeradorSoloSiRevisada CHECK ((estado = 'PENDIENTE' AND moderadorId IS NULL) OR (estado != 'PENDIENTE' AND moderadorId IS NOT NULL))
);
