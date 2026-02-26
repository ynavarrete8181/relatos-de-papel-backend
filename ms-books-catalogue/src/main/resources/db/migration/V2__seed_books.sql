INSERT INTO books (id, title, author, price, cover, description) VALUES
('1','Cuentos al borde de la tinta','Lucía Ferrer',12.99,'https://picsum.photos/seed/book1/300/420','Relatos cortos donde cada página guarda un secreto.'),
('2','Relatos de Papel','Andrés Molina',15.50,'https://picsum.photos/seed/book2/300/420','Historias que nacen en una librería y cambian al lector.'),
('3','La ciudad de los marcapáginas','Marina Soto',9.75,'https://picsum.photos/seed/book3/300/420','Un viaje fantástico en el que los libros abren puertas.'),
('4','Poesía para tardes de lluvia','Sergio Valdés',8.99,'https://picsum.photos/seed/book4/300/420','Versos íntimos para acompañar el sonido de la lluvia.'),
('5','El último capítulo','Nora Campos',13.20,'https://picsum.photos/seed/book5/300/420','Una novela que te obliga a replantearte todo al final.'),
('6','Cartas a una librería vacía','Diego Rivas',10.50,'https://picsum.photos/seed/book6/300/420','Correspondencia íntima con aroma a papel antiguo.'),
('7','El coleccionista de portadas','Paula Ibarra',11.99,'https://picsum.photos/seed/book7/300/420','Un misterio que se esconde entre ilustraciones y tinta.'),
('8','Manual para perderse en bibliotecas','Héctor Salas',14.00,'https://picsum.photos/seed/book8/300/420','Ensayos y anécdotas para lectores con alma de explorador.'),
('9','La noche de los escritores','Camila Duarte',16.25,'https://picsum.photos/seed/book9/300/420','Una reunión clandestina donde cada historia tiene precio.'),
('10','La tinta y el silencio','Rafael Montenegro',7.95,'https://picsum.photos/seed/book10/300/420','Microrrelatos minimalistas para leer en un respiro.'),
('11','Atlas de mundos imaginarios','Valentina Cruz',18.60,'https://picsum.photos/seed/book11/300/420','Mapas, criaturas y leyendas de universos que no existen… aún.'),
('12','El club del párrafo perdido','Julián Paredes',12.40,'https://picsum.photos/seed/book12/300/420','Una aventura literaria sobre un texto que nadie recuerda haber escrito.')
ON CONFLICT (id) DO NOTHING;
