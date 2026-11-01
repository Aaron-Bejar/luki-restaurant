import { cerrarTurnoSeguro } from "./cierre-turno";

describe("cierre seguro de turno", () => {
  it("revoca el turno remoto antes de eliminar su token local", async () => {
    const pasos: string[] = [];

    await cerrarTurnoSeguro("token-de-prueba", {
      eliminarToken: async () => {
        pasos.push("eliminar");
      },
      revocarTurno: async (token) => {
        pasos.push(`revocar:${token}`);
      },
    });

    expect(pasos).toEqual(["revocar:token-de-prueba", "eliminar"]);
  });

  it("conserva el token local si el servidor no confirma la revocación", async () => {
    const eliminarToken = jest.fn<Promise<void>, []>().mockResolvedValue();

    await expect(
      cerrarTurnoSeguro("token-de-prueba", {
        eliminarToken,
        revocarTurno: async () => {
          throw new Error("Sin conexión");
        },
      }),
    ).rejects.toThrow("Sin conexión");

    expect(eliminarToken).not.toHaveBeenCalled();
  });

  it("elimina cualquier token local si no existe una sesión en memoria", async () => {
    const eliminarToken = jest.fn<Promise<void>, []>().mockResolvedValue();
    const revocarTurno = jest.fn<Promise<void>, [string]>().mockResolvedValue();

    await cerrarTurnoSeguro(null, { eliminarToken, revocarTurno });

    expect(revocarTurno).not.toHaveBeenCalled();
    expect(eliminarToken).toHaveBeenCalledTimes(1);
  });
});
