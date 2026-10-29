jest.mock("@/lib/supabase", () => ({
  supabase: { rpc: jest.fn() },
}));

import { supabase } from "@/lib/supabase";

import { eliminarCategoria, establecerDisponibilidadPlato, listarCarta } from "./carta";

describe("servicio de carta", () => {
  beforeEach(() => jest.clearAllMocks());

  it("consulta la carta completa con el token de sesión recibido", async () => {
    jest.mocked(supabase.rpc).mockResolvedValueOnce({ data: [], error: null } as never);
    await expect(listarCarta("sesion-prueba")).resolves.toEqual([]);
    expect(supabase.rpc).toHaveBeenCalledWith("listar_carta", { p_token_sesion: "sesion-prueba" });
  });

  it("cambia disponibilidad y elimina categoría únicamente mediante RPC", async () => {
    jest.mocked(supabase.rpc)
      .mockResolvedValueOnce({ data: { id: 4, activo: false }, error: null } as never)
      .mockResolvedValueOnce({ error: null } as never);

    await establecerDisponibilidadPlato("sesion-prueba", 4, false);
    await eliminarCategoria("sesion-prueba", 9);

    expect(supabase.rpc).toHaveBeenNthCalledWith(1, "establecer_disponibilidad_plato", { p_activo: false, p_plato_id: 4, p_token_sesion: "sesion-prueba" });
    expect(supabase.rpc).toHaveBeenNthCalledWith(2, "eliminar_categoria", { p_categoria_id: 9, p_token_sesion: "sesion-prueba" });
  });
});
