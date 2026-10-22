jest.mock("expo-secure-store", () => ({
  deleteItemAsync: jest.fn(),
  getItemAsync: jest.fn(),
  setItemAsync: jest.fn(),
}));

import * as SecureStore from "expo-secure-store";

import { TOKEN_SESION_KEY, eliminarTokenSesion, guardarTokenSesion, leerTokenSesion } from "./secure-session";

describe("almacenamiento de sesión", () => {
  beforeEach(() => jest.clearAllMocks());

  it("persiste únicamente el token bajo una clave dedicada", async () => {
    await guardarTokenSesion("token-de-prueba");
    expect(SecureStore.setItemAsync).toHaveBeenCalledWith(TOKEN_SESION_KEY, "token-de-prueba");
    expect(SecureStore.setItemAsync).toHaveBeenCalledTimes(1);
  });

  it("lee y elimina el token al cerrar turno", async () => {
    jest.mocked(SecureStore.getItemAsync).mockResolvedValueOnce("token-de-prueba");
    await expect(leerTokenSesion()).resolves.toBe("token-de-prueba");
    await eliminarTokenSesion();
    expect(SecureStore.deleteItemAsync).toHaveBeenCalledWith(TOKEN_SESION_KEY);
  });
});
