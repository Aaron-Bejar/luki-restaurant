export const PIN_LENGTH = 4;

export function agregarDigito(pin: string, digito: string): string {
  if (!/^\d$/.test(digito) || pin.length >= PIN_LENGTH) return pin;
  return `${pin}${digito}`;
}

export function borrarDigito(pin: string): string {
  return pin.slice(0, -1);
}

export function pinCompleto(pin: string): boolean {
  return /^\d{4}$/.test(pin);
}
