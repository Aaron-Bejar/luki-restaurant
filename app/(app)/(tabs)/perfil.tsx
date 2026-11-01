import { Pressable, Text, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { useSesion } from "@/auth/session-context";
import { ALTURA_BARRA_TABS } from "@/navigation/tabs";

export default function PerfilScreen() {
  const { cerrarTurno, sesion } = useSesion();
  const insets = useSafeAreaInsets();

  return <View className="flex-1 justify-between bg-[--color-surface] px-6 pt-12" style={{ paddingBottom: ALTURA_BARRA_TABS + 16 + insets.bottom }}>
    <View>
      <Text className="text-3xl font-bold text-[--color-ink]">Mi perfil</Text>
      <Text className="mt-3 text-base text-[--color-muted]">{sesion?.nombre}</Text>
    </View>
    <Pressable accessibilityLabel="Cerrar sesión" accessibilityRole="button" className="items-center rounded-2xl bg-[--color-danger] px-5 py-4" onPress={() => void cerrarTurno()}>
      <Text className="text-base font-bold text-white">Cerrar sesión</Text>
    </Pressable>
  </View>;
}
