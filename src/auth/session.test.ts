import { puedeAccederARol, sesionExpirada, validarPinTurno } from "./session";

describe("sesión operativa de interfaz", () => {
  it("exige un PIN numérico de cuatro dígitos", () => {
    expect(validarPinTurno({ pin: "1234" })).toBeNull();
    expect(validarPinTurno({ pin: "12a4" })).toMatch(/cuatro dígitos/i);
  });

  it("bloquea una sesión vencida y separa los permisos de owner", () => {
    const ahora = new Date("2026-10-21T12:00:00.000Z");
    expect(sesionExpirada("2026-10-21T11:59:59.000Z", ahora)).toBe(true);
    expect(sesionExpirada("2026-10-21T12:00:01.000Z", ahora)).toBe(false);
    expect(puedeAccederARol("owner", ["owner"])).toBe(true);
    expect(puedeAccederARol("waitress", ["owner"])).toBe(false);
  });
});
