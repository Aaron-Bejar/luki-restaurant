import type { RolUsuario } from "@/types/supabase";

export type PestanaPrincipal = "mesas" | "carta" | "personal" | "perfil";

const pestanasPorRol: Record<RolUsuario, readonly PestanaPrincipal[]> = {
  owner: ["mesas", "carta", "personal", "perfil"],
  waitress: ["mesas", "carta", "perfil"],
};

export function pestanasPermitidas(rol: RolUsuario): readonly PestanaPrincipal[] {
  return pestanasPorRol[rol];
}

export function puedeVerPestana(rol: RolUsuario, pestana: PestanaPrincipal): boolean {
  return pestanasPermitidas(rol).includes(pestana);
}
