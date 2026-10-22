import { Redirect, type Href } from "expo-router";
import { Image, Pressable, Text, View } from "react-native";
import { useRef, useState } from "react";

import { agregarDigito, borrarDigito, pinCompleto } from "@/auth/pin-pad";
import { useSesion } from "@/auth/session-context";

const TECLAS = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];

export default function InicioTurnoScreen() {
  const { iniciarTurno, sesion } = useSesion();
  const [pin, setPin] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [enviando, setEnviando] = useState(false);
  const solicitudEnCurso = useRef(false);

  if (sesion) return <Redirect href={"/(app)" as Href} />;

  async function validarPin(pinIngresado: string) {
    if (solicitudEnCurso.current) return;

    solicitudEnCurso.current = true;
    setEnviando(true);
    setError(null);

    try {
      await iniciarTurno({ pin: pinIngresado });
    } catch (caughtError) {
      setPin("");
      setError(caughtError instanceof Error ? caughtError.message : "No se pudo iniciar el turno.");
    } finally {
      solicitudEnCurso.current = false;
      setEnviando(false);
    }
  }

  function presionarDigito(digito: string) {
    if (enviando) return;

    const siguientePin = agregarDigito(pin, digito);
    if (siguientePin === pin) return;

    setPin(siguientePin);
    setError(null);

    if (pinCompleto(siguientePin)) void validarPin(siguientePin);
  }

  function borrar() {
    if (enviando) return;
    setPin((valorActual) => borrarDigito(valorActual));
    setError(null);
  }

  return (
    <View className="flex-1 bg-[--color-surface] px-6 py-12">
      <View className="items-center">
        <Image accessibilityLabel="Logo de Luki" className="h-36 w-36 rounded-full" resizeMode="cover" source={require("@/assets/images/brand/luki-logo.png")} />
        <Text className="mt-8 text-center text-3xl font-bold tracking-tight text-[--color-ink]">Ingresa tu PIN</Text>
        <Text className="mt-3 text-center text-base leading-6 text-[--color-muted]">Usa tu código de cuatro dígitos para iniciar turno.</Text>

        <View accessibilityLabel={`PIN: ${pin.length} de 4 dígitos ingresados`} className="mt-10 flex-row gap-4">
          {[0, 1, 2, 3].map((indice) => (
            <View key={indice} className={`h-4 w-4 rounded-full ${indice < pin.length ? "bg-[--color-primary]" : "border-2 border-[--color-line] bg-white"}`} />
          ))}
        </View>

        <View className="mt-6 h-6">
          {enviando ? <Text accessibilityLiveRegion="polite" className="text-sm text-[--color-muted]">Verificando PIN…</Text> : null}
          {error ? <Text accessibilityLiveRegion="polite" className="text-center text-sm text-[--color-danger]">{error}</Text> : null}
        </View>
      </View>

      <View accessibilityLabel="Teclado numérico" className="mt-auto gap-3">
        <View className="flex-row flex-wrap justify-between gap-y-3">
          {TECLAS.map((digito) => <Tecla key={digito} digito={digito} deshabilitada={enviando} onPress={presionarDigito} />)}
        </View>
        <View className="flex-row items-center justify-between">
          <View className="h-16 w-[30%]" />
          <Tecla digito="0" deshabilitada={enviando} onPress={presionarDigito} />
          <Pressable accessibilityLabel="Borrar último dígito" accessibilityRole="button" accessibilityState={{ disabled: enviando || pin.length === 0 }} className="h-16 w-[30%] items-center justify-center rounded-2xl disabled:opacity-40" disabled={enviando || pin.length === 0} onPress={borrar}>
            <Text className="text-xl font-semibold text-[--color-ink]">⌫</Text>
          </Pressable>
        </View>
      </View>
    </View>
  );
}

function Tecla({ deshabilitada, digito, onPress }: { deshabilitada: boolean; digito: string; onPress: (digito: string) => void }) {
  return (
    <Pressable accessibilityLabel={`Número ${digito}`} accessibilityRole="button" accessibilityState={{ disabled: deshabilitada }} className="h-16 w-[30%] items-center justify-center rounded-2xl bg-white active:bg-[#e6f5ed] disabled:opacity-40" disabled={deshabilitada} onPress={() => onPress(digito)}>
      <Text className="text-2xl font-semibold text-[--color-ink]">{digito}</Text>
    </Pressable>
  );
}
