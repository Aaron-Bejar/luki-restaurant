import { Pressable, Text, View } from "react-native";

import { useSesion } from "@/auth/session-context";

export default function TurnoActivoScreen() {
  const { cerrarTurno, sesion } = useSesion();
  if (!sesion) return null;
  const etiquetaRol = sesion.rol === "owner" ? "Dueño" : "Mesera";

  return (
    <View className="flex-1 justify-between bg-[--color-surface] px-6 py-12">
      <View>
        <Text className="text-sm font-semibold uppercase tracking-widest text-[--color-primary]">Turno activo</Text>
        <Text className="mt-3 text-4xl font-bold text-[--color-ink]">Hola, {sesion.nombre}</Text>
        <View className="mt-6 self-start rounded-full bg-[#e6f5ed] px-4 py-2"><Text className="font-semibold text-[--color-primary]">Rol: {etiquetaRol}</Text></View>
        <Text className="mt-8 text-base leading-6 text-[--color-muted]">Ya puedes comenzar a operar. Las pantallas de mesas y pedidos se integrarán en este espacio.</Text>
      </View>
      <Pressable accessibilityRole="button" className="items-center rounded-2xl border border-[--color-line] bg-white px-5 py-4" onPress={() => void cerrarTurno()}><Text className="text-base font-bold text-[--color-ink]">Cerrar turno</Text></Pressable>
    </View>
  );
}
