
`timescale 1ns / 1ps // escala de tiempo: 1ns con presicion de 1ps
//////////////////////////////////////////////////////////////////////////////////
// Laboratorio de Sistemas Digitales, 1er semestre, 2018
// Laboratorio 3
// Integrantes:
// - Tomas Munoz ROL: 201621029-6
// - Mauricio Aravena
// - Oscar Cordova
// Grupo 1000
// Modulo 1: Led Switch
// Breve descripcion: el modulo consiste en 16 switches que prenden 16 LEDs
// cada switch encargandose de prender 1 LED.
//////////////////////////////////////////////////////////////////////////////////


module led_switch(
	input [15:0] SW, // definimos un bus de entrada de 16 bit cada uno representando un switch
	output [15:0] LED // definimos un bus de 16 pines de salida, cada uno representando un LED
    );

    /*
    como se puede ver en el datasheet del nexys 4, los switches pueden tener 2 estados,
    HIGH (3.3 V o 1.8V) o LOW, como los LEDs vienen incorporado con resistencias, bastara con
    conectar directamente cada switch con su respectivo LED mediante assign.
    */
    assign LED = SW; // conecta cada switch con cada LED
endmodule
