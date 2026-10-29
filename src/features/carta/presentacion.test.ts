import { filtrarPlatosPorCategoria, textoDisponibilidad } from "./presentacion";

const plato = (id: number, categoria_id: number, activo: boolean) => ({ id, categoria_id, activo }) as never;

describe("presentación de carta", () => {
  it("mantiene platos activos e inactivos al filtrar", () => {
    const platos = [plato(1, 10, true), plato(2, 10, false), plato(3, 20, true)];
    expect(filtrarPlatosPorCategoria(platos, 10).map(({ id }) => id)).toEqual([1, 2]);
  });

  it("describe la disponibilidad sin ocultar el producto", () => {
    expect(textoDisponibilidad(true)).toBe("Disponible");
    expect(textoDisponibilidad(false)).toBe("No disponible");
  });
});
