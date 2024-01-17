// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MiToken.sol";

contract MiContrato {
    address public owner;
    uint public sueldoAcumulado;
    uint public tiempoInicio;
    bool public temporizadorActivo;
    uint public sueldoPorHora = 10; // Número inicial de euros por hora
    uint public tokensHoraExtra = 1; // Tokens por hora extra
    uint public tokensAcumulados; // Cantidad de tokens acumulados
    uint public tiempoTranscurrido; // Tiempo laboral hecho
    uint public tiempoTotal; // Tiempo total transcurrido
    uint public cantidadTokens;
    uint public DiasLibres;
    uint public PrecioDiasLibres ; 
    MiToken public MisTokens;

    // Eventos
    event ValorActualizado(uint nuevoValor);
    event TemporizadorIniciado(uint tiempoInicio);
    event TemporizadorDetenido(uint tiempoFinal);
    event TokensAcumulados(uint cantidadTokens);
    event TiempoResetado();

    // Modificador para asegurar que solo el propietario puede realizar ciertas operaciones
    modifier soloPropietario() {
        require(msg.sender == owner, "No eres el propietario");
        _;
    }

    // Constructor del contrato, establece el propietario inicial y el valor inicial
    constructor() {
        owner = msg.sender;
        sueldoAcumulado = 0;
        DiasLibres = 12;
        PrecioDiasLibres = 20;
        temporizadorActivo = false;
        MisTokens = new MiToken(1); // Ajusta la cantidad inicial de tokens según tus necesidades
    }

    // Función para retirar el saldo 
    function retirarSaldo(uint nuevoValor) external soloPropietario {
        sueldoAcumulado -= nuevoValor;
        emit ValorActualizado(sueldoAcumulado);
    }

    // Función para añadir tiempo y simular el paso del tiempo
    function sumarTiempo(uint nuevoValor) external soloPropietario {
        tiempoTotal += nuevoValor;
        emit ValorActualizado(tiempoTotal);
    }

     // Función para obtener el totalSupply de MisTokens
    function obtenerTotalSupply() public returns (uint256) {
        return MisTokens.totalSupply();
    }

    // Función para canjear tokens por dias libres
    function comprarDiasLibres() public {
         MisTokens.quitarTokens(PrecioDiasLibres);// Transfiere tokens al usuario
         cantidadTokens = cantidadTokens - PrecioDiasLibres;
         DiasLibres = DiasLibres + 1;
    }


    // Función para cambiar de día, calcula el sueldo acumulado y los tokens ganados ese dia
    function nuevoDia() public {
        if (tiempoTotal > 28800){
        sueldoAcumulado = (28800 / 3600) * sueldoPorHora + sueldoAcumulado;
        tiempoTotal = tiempoTotal - 28800;
        cantidadTokens = tiempoTotal  / 3600 * tokensHoraExtra;
        tokensAcumulados += cantidadTokens;
        MisTokens.agregarNuevosTokens(cantidadTokens); // Transfiere tokens al usuario
        emit ValorActualizado(MisTokens.totalSupply());}
        else {
             sueldoAcumulado = (tiempoTotal / 3600) * sueldoPorHora + sueldoAcumulado;
        }
            tiempoTotal = 0;
        emit TiempoResetado();
    }



    // Función para iniciar el temporizador
    function entrada() external soloPropietario {
        require(!temporizadorActivo, unicode"El temporizador ya está activo");
        tiempoInicio = block.timestamp;
        temporizadorActivo = true;
        emit TemporizadorIniciado(tiempoInicio);
    }

    // Función para detener el temporizador y acumular tokens
    function salida() external soloPropietario {
        require(temporizadorActivo, unicode"El temporizador no está activo");
        tiempoTranscurrido = block.timestamp - tiempoInicio;
        tiempoTotal += tiempoTranscurrido;
        // Resetea el temporizador
        tiempoInicio = 0;
        temporizadorActivo = false;
        emit TemporizadorDetenido(tiempoTotal);
    }

    // Función para ajustar el sueldo por hora
    function ajustarSueldoPorHora(uint nuevaSueldo) external soloPropietario {
        sueldoPorHora = nuevaSueldo;
    }

      // Función para ajustar el numero de tokens por dia libre
    function ajustarTokenDiaLibre(uint precio) external soloPropietario {
        PrecioDiasLibres = precio;
    }

      // Función para ajustar el numero de tokens por hora extra
    function ajustarTokenporHoraExtra(uint precio) external soloPropietario {
       tokensHoraExtra = precio;
    }
}


