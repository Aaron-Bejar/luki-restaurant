import * as SecureStore from "expo-secure-store";

const TOKEN_SESION_KEY = "luki.token_sesion";

/** El único dato de sesión persistido en el dispositivo es el token. */
export async function guardarTokenSesion(tokenSesion: string): Promise<void> {
  await SecureStore.setItemAsync(TOKEN_SESION_KEY, tokenSesion);
}

export async function leerTokenSesion(): Promise<string | null> {
  return SecureStore.getItemAsync(TOKEN_SESION_KEY);
}

export async function eliminarTokenSesion(): Promise<void> {
  await SecureStore.deleteItemAsync(TOKEN_SESION_KEY);
}

export { TOKEN_SESION_KEY };
