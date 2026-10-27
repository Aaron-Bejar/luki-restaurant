import { presentarEstadoMesa, resumenMesas } from "./presentacion";

describe("presentación de mesas", () => {
  it("distingue visual y accesiblemente una mesa libre de una ocupada", () => {
    expect(presentarEstadoMesa("libre")).toMatchObject({
      accesibilidad: "Mesa libre",
      etiqueta: "Libre",
    });
    expect(presentarEstadoMesa("ocupada")).toMatchObject({
      accesibilidad: "Mesa ocupada",
      etiqueta: "Ocupada",
    });
  });

  it("resume correctamente las siete mesas del salón", () => {
    expect(resumenMesas(7)).toBe("7 mesas en el salón");
  });
});
