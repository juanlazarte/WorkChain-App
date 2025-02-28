## WORKCHAIN APP

**DESCRIPCIÓN DEL PROYECTO**

🏗 ContractFactory
    El ContractFactory es el contrato principal encargado de la creación y gestión de los contratos de trabajo. Permite a los empleadores desplegar WorkContracts, asegurando que cada oferta de trabajo tenga su propio contrato inteligente en la blockchain.

💼 WorkContract
El WorkContract representa un contrato de trabajo entre un empleador y un freelancer.

    Permite depositar fondos como pago por el trabajo.
    Gestiona el inicio y la finalización del trabajo.
    Permite la liberación del pago cuando el trabajo es aprobado.
    Permite abrir disputas si hay desacuerdos.

⚖ WorkDAO
El WorkDAO es el contrato encargado de la resolución de disputas.

    Recibe las disputas abiertas desde los WorkContracts.
    Permite a una comunidad de validadores decidir si el pago debe ir al freelancer o devolverse al empleador.
    Se asegura de que el proceso sea transparente y descentralizado.
