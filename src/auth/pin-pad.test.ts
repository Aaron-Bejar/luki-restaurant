import { agregarDigito, borrarDigito, pinCompleto } from "./pin-pad";

describe("teclado de PIN", () => {
  it("agrega hasta cuatro dígitos válidos sin aceptar caracteres", () => {
    expect(agregarDigito("123", "4")).toBe("1234");
    expect(agregarDigito("1234", "5")).toBe("1234");
    expect(agregarDigito("12", "a")).toBe("12");
  });

  it("borra el último dígito e identifica cuándo validar automáticamente", () => {
    expect(borrarDigito("1234")).toBe("123");
    expect(pinCompleto("1234")).toBe(true);
    expect(pinCompleto("123")).toBe(false);
  });
});
