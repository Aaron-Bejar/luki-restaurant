import type { Carta } from "@/types/supabase";

export function filtrarPlatosPorCategoria(platos: readonly Carta[], categoriaId: number | null): Carta[] {
  return platos.filter((plato) => categoriaId === null || plato.categoria_id === categoriaId);
}

export function textoDisponibilidad(activo: boolean): string {
  return activo ? "Disponible" : "No disponible";
}
