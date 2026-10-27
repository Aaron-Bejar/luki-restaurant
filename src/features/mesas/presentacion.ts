import type { EstadoMesa } from "@/types/supabase";

export type EstadoMesaPresentacion = {
  accesibilidad: string;
  etiqueta: "Libre" | "Ocupada";
  clase: string;
};

export function presentarEstadoMesa(estado: EstadoMesa): EstadoMesaPresentacion {
  if (estado === "ocupada") {
    return {
      accesibilidad: "Mesa ocupada",
      etiqueta: "Ocupada",
      clase: "bg-[#fff4df] text-[#7a4b00]",
    };
  }

  return {
    accesibilidad: "Mesa libre",
    etiqueta: "Libre",
    clase: "bg-[#e6f5ed] text-[--color-primary]",
  };
}

export function resumenMesas(cantidad: number): string {
  return `${cantidad} ${cantidad === 1 ? "mesa" : "mesas"} en el salón`;
}
