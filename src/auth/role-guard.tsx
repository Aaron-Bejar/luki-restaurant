import { Redirect, Slot, type Href } from "expo-router";
import { ActivityIndicator, View } from "react-native";

import { puedeAccederARol } from "@/auth/session";
import { useSesion } from "@/auth/session-context";
import type { RolUsuario } from "@/types/supabase";

export function RoleGuard({ rolesPermitidos }: { rolesPermitidos: readonly RolUsuario[] }) {
  const { cargandoSesion, sesion } = useSesion();

  if (cargandoSesion) {
    return <View className="flex-1 items-center justify-center bg-[--color-surface]"><ActivityIndicator color="#1eab64" /></View>;
  }
  if (!sesion) return <Redirect href={"/(auth)" as Href} />;
  if (!puedeAccederARol(sesion.rol, rolesPermitidos)) return <Redirect href={"/(app)" as Href} />;
  return <Slot />;
}
