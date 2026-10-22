import { type Href, useRouter } from "expo-router";
import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";

import { type PinTurno, type SesionDeInterfaz, sesionExpirada, validarPinTurno } from "@/auth/session";
import { eliminarTokenSesion, guardarTokenSesion, leerTokenSesion } from "@/lib/secure-session";
import { cerrarTurno as cerrarTurnoRemoto, iniciarTurno } from "@/services/usuarios";

type SesionContexto = {
  cargandoSesion: boolean;
  cerrarTurno: () => Promise<void>;
  iniciarTurno: (credenciales: PinTurno) => Promise<void>;
  sesion: SesionDeInterfaz | null;
  tokenSesion: string | null;
};

const SessionContext = createContext<SesionContexto | null>(null);

export function SessionProvider({ children }: { children: React.ReactNode }) {
  const [cargandoSesion, setCargandoSesion] = useState(true);
  const [sesion, setSesion] = useState<SesionDeInterfaz | null>(null);
  const [tokenSesion, setTokenSesion] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    async function prepararSesion() {
      try {
        // No se restauran metadatos de UI: no se persisten fuera de esta sesión en memoria.
        await leerTokenSesion();
      } finally {
        setCargandoSesion(false);
      }
    }

    void prepararSesion();
  }, []);

  const iniciar = useCallback(async ({ pin }: PinTurno) => {
    const errorDeValidacion = validarPinTurno({ pin });
    if (errorDeValidacion) throw new Error(errorDeValidacion);

    const resultado = await iniciarTurno(pin);
    await guardarTokenSesion(resultado.token_sesion);

    setTokenSesion(resultado.token_sesion);
    setSesion({ expiraEn: resultado.expira_en, nombre: resultado.nombre, rol: resultado.rol });
  }, []);

  const cerrar = useCallback(async () => {
    try {
      if (tokenSesion) await cerrarTurnoRemoto(tokenSesion);
    } finally {
      await eliminarTokenSesion();
      setTokenSesion(null);
      setSesion(null);
      router.replace("/(auth)" as Href);
    }
  }, [router, tokenSesion]);

  useEffect(() => {
    if (sesion && sesionExpirada(sesion.expiraEn)) void cerrar();
  }, [cerrar, sesion]);

  const value = useMemo(
    () => ({ cargandoSesion, cerrarTurno: cerrar, iniciarTurno: iniciar, sesion, tokenSesion }),
    [cargandoSesion, cerrar, iniciar, sesion, tokenSesion],
  );

  return <SessionContext.Provider value={value}>{children}</SessionContext.Provider>;
}

export function useSesion(): SesionContexto {
  const contexto = useContext(SessionContext);
  if (!contexto) throw new Error("useSesion debe usarse dentro de SessionProvider.");
  return contexto;
}
