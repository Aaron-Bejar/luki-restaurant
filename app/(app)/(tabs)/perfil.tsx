import { Pressable, Text, View } from "react-native";
import { Image } from "expo-image";
import { useState } from "react";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { useSesion } from "@/auth/session-context";
import { ALTURA_BARRA_TABS } from "@/navigation/tabs";

export default function PerfilScreen() {
  const { cerrarTurno, sesion } = useSesion();
  const insets = useSafeAreaInsets();
  const [cerrando, setCerrando] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const rol = sesion?.rol === "owner" ? "Administrador" : "Mesera";
  const inicial =
    sesion?.nombre.trim().split(/\s+/).slice(0, 2).map((parte) => parte.charAt(0)).join("").toLocaleUpperCase("es-PE") || "?";

  async function confirmarCierre() {
    if (cerrando) return;

    setCerrando(true);
    setError(null);
    try {
      await cerrarTurno();
    } catch (caughtError) {
      setError(
        caughtError instanceof Error
          ? caughtError.message
          : "No se pudo cerrar el turno. Verifica tu conexión e inténtalo de nuevo.",
      );
      setCerrando(false);
    }
  }

  return (
    <View
      className="flex-1 justify-between bg-[#F9F9F9] px-[22px] pt-12"
      style={{ paddingBottom: ALTURA_BARRA_TABS + 16 + insets.bottom }}
    >
      <View>
        <Text className="text-4xl font-semibold tracking-tight text-[--color-ink]">
          Perfil
        </Text>

        <View
          accessibilityLabel={`Inicial de ${sesion?.nombre ?? "usuario"}`}
          className="relative mt-12 h-28 w-28 self-center items-center justify-center rounded-full bg-[#9DAFA1]"
        >
          <Text className="text-2xl font-semibold text-white">
            {inicial}
          </Text>
          <View className="absolute bottom-1 right-1 h-5 w-5 rounded-full border-2 border-[#F9F9F9] bg-[#1FA55E]" />
        </View>
        <Text className="mt-4 text-center text-2xl font-semibold text-[--color-ink]">{sesion?.nombre}</Text>

        <View className="mt-8 border-t border-[--color-line]">
          <View className="min-h-16 flex-row items-center justify-between border-b border-[--color-line] py-3">
            <Text className="text-[15px] text-[--color-muted]">Rol</Text>
            <Text
              accessibilityLabel={`Rol: ${rol}`}
              className="mt-1 text-[15px] text-[--color-ink]"
            >
              {rol}
            </Text>
          </View>
          <View className="min-h-16 flex-row items-center justify-between border-b border-[--color-line] py-3">
            <Text className="text-[15px] text-[--color-muted]">Estado</Text>
            <View className="flex-row items-center gap-2"><View className="h-2 w-2 rounded-full bg-[#1FA55E]" /><Text className="text-[15px] text-[#1FA55E]">Activo</Text></View>
          </View>
        </View>
      </View>

      <View>
        {error ? (
          <Text
            accessibilityLiveRegion="polite"
            className="mb-4 text-center text-sm text-[--color-danger]"
          >
            {error}
          </Text>
        ) : null}
        <Pressable
          accessibilityLabel="Cerrar sesión"
          accessibilityRole="button"
          accessibilityState={{ disabled: cerrando }}
          className="h-[52px] w-full flex-row items-center justify-center gap-2 rounded-full border border-[#E3E1D8] bg-transparent px-6 disabled:opacity-50"
          disabled={cerrando}
          onPress={() => void confirmarCierre()}
        >
          <Image source={require("../../../assets/icons/log-out.svg")} style={{ width: 20, height: 20 }} tintColor="#C62F35" />
          <Text className="text-[15px] font-semibold text-[#C62F35]">
            {cerrando ? "Cerrando turno…" : "Cerrar sesión"}
          </Text>
        </Pressable>
      </View>
    </View>
  );
}
