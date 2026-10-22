import { RoleGuard } from "@/auth/role-guard";

/** Reserva las rutas administrativas para las pantallas exclusivas de owner. */
export default function OwnerLayout() {
  return <RoleGuard rolesPermitidos={["owner"]} />;
}
