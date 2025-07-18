# 💠 Donare Smart Contracts

Contratos inteligentes que gobiernan la creación, administración y ejecución de campañas solidarias descentralizadas dentro de la plataforma [Donare](https://donare.xyz).

## 📦 Contratos

### `CampaignFactory.sol`

Contrato responsable de:

- Crear nuevas campañas (`Campaign`).
- Asociar cada campaña con su creador.
- Evitar múltiples campañas activas o en revisión del mismo creador.
- Registrar el historial de campañas creadas.

### `Campaign.sol`

Contrato individual que representa una campaña solidaria. Cada campaña se despliega como contrato independiente.

Funciones principales:

- Registro de donaciones con transferencia directa al beneficiario.
- Control de estado (`InReview`, `Approved`, `Rejected`, `Paused`, `Finalized`).
- Finalización automática al cumplir objetivo (`goal`) o al pasar la fecha límite (`deadline`).
- Control por parte del creador (modificación) y del equipo Donare (validación).

---

## ⚙️ Comportamiento del sistema

### Creación de campaña

- El usuario crea una campaña desde el frontend.
- La `CampaignFactory` verifica que no tenga otra campaña activa o en revisión.
- Se despliega un nuevo contrato `Campaign`:
  - `creator` y `beneficiary` = address del usuario.
  - `owner` = address administrada por Donare (con permisos para aprobar/rechazar/pausar).

### Estados posibles

| Estado         | Descripción |
|----------------|-------------|
| `InReview`     | Estado inicial al crear o editar la campaña. |
| `Approved`     | Puede recibir donaciones. |
| `Rejected`     | Campaña denegada por Donare. |
| `Paused`       | Campaña suspendida por razones de seguridad. |
| `Finalized`    | No se pueden recibir más donaciones. |

### Finalización automática

Una campaña se **finaliza automáticamente** si:

- Se alcanza el objetivo (`raised >= goal`).
- Se supera el `deadline`.

También se puede forzar manualmente llamando a `finalizeIfExpired()`.

---

## 💰 Donaciones

- Solo se permiten si la campaña está `Approved`, no está `Paused`, y no está `Finalized`.
- Cada donación se transfiere **directamente al beneficiario** en tiempo real.
- No se almacenan fondos en el contrato (`non-custodial`).

---

## 🚫 Reembolsos

- **No se permiten reembolsos** de ningún tipo una vez realizada una donación.
- Esto garantiza trazabilidad y evita inconsistencias si el beneficiario ya recibió el dinero.

---

## 👥 Roles

| Rol        | Permisos                                                              |
|------------|-----------------------------------------------------------------------|
| `creator`  | Puede editar la campaña (la vuelve a estado `InReview`).             |
| `owner`    | Solo el equipo Donare. Puede aprobar, rechazar o pausar campañas.     |

---

## 📂 Estructura del repositorio

donare-smart-contracts/
├── contracts/
│ ├── Campaign.sol
│ └── CampaignFactory.sol
├── scripts/ # Scripts de deploy (en construcción)
├── test/ # Pruebas unitarias
├── hardhat.config.ts
├── package.json
└── README.md


---

## ✅ Requisitos y herramientas

- Solidity ^0.8.20
- Hardhat + TypeScript
- OpenZeppelin Contracts
- Ethers.js / TypeChain
- Polygon Amoy testnet

---

## 📜 License

MIT — desarrollado como proyecto académico y experimental.
