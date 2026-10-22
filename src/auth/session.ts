import type { RolUsuario } from "@/types/supabase";

export type SesionDeInterfaz = {
  expiraEn: string;
  nombre: string;
  rol: RolUsuario;
};

export type PinTurno = {
  pin: string;
};

export function validarPinTurno({ pin }: PinTurno): string | null {
  if (!/^\d{4}$/.test(pin)) return "El PIN debe tener exactamente cuatro dígitos.";
  return null;
}

export function sesionExpirada(expiraEn: string, ahora = new Date()): boolean {
  const vencimiento = new Date(expiraEn);
  return Number.isNaN(vencimiento.getTime()) || vencimiento <= ahora;
}

export function puedeAccederARol(rol: RolUsuario, rolesPermitidos: readonly RolUsuario[]): boolean {
  return rolesPermitidos.includes(rol);
}
