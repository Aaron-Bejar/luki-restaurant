import { StatusBar } from "expo-status-bar";
import { SafeAreaView, Text, View } from "react-native";

export default function HomeScreen() {
  return (
    <SafeAreaView className="flex-1 bg-slate-950">
      <StatusBar style="light" />

      <View className="flex-1 justify-between px-6 py-8">
        <View>
          <View className="mb-10 flex-row items-center justify-between">
            <View className="h-11 w-11 items-center justify-center rounded-2xl bg-orange-500">
              <Text className="text-xl">🍽️</Text>
            </View>
            <View className="rounded-full border border-emerald-400/30 bg-emerald-400/10 px-3 py-1.5">
              <Text className="text-xs font-semibold text-emerald-300">
                CONEXIÓN LISTA
              </Text>
            </View>
          </View>

          <Text className="mb-3 text-4xl font-bold tracking-tight text-white">
            Luki
          </Text>
          <Text className="max-w-xs text-lg leading-7 text-slate-300">
            Pedidos claros, mesas ágiles y cuentas por persona.
          </Text>

          <View className="mt-10 gap-3">
            <FeatureCard
              emoji="👥"
              title="Pedidos por persona"
              description="Organiza cada comanda de forma simple."
            />
            <FeatureCard
              emoji="🪑"
              title="Mesas en tiempo real"
              description="Consulta su estado desde cualquiera de los dispositivos."
            />
            <FeatureCard
              emoji="✓"
              title="Listo para configurar"
              description="NativeWind y Expo están funcionando correctamente."
            />
          </View>
        </View>

        <View className="rounded-3xl bg-orange-500 p-5">
          <Text className="text-base font-bold text-slate-950">
            Próximo paso
          </Text>
          <Text className="mt-1 text-sm leading-5 text-slate-900">
            Configurar la conexión segura con Supabase.
          </Text>
        </View>
      </View>
    </SafeAreaView>
  );
}

type FeatureCardProps = {
  emoji: string;
  title: string;
  description: string;
};

function FeatureCard({ emoji, title, description }: FeatureCardProps) {
  return (
    <View className="flex-row items-center rounded-2xl border border-slate-800 bg-slate-900 p-4">
      <Text className="mr-4 text-2xl" accessibilityLabel={title}>
        {emoji}
      </Text>
      <View className="flex-1">
        <Text className="text-base font-semibold text-white">{title}</Text>
        <Text className="mt-1 text-sm leading-5 text-slate-400">
          {description}
        </Text>
      </View>
    </View>
  );
}
