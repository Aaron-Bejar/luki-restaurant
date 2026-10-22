import { RoleGuard } from "@/auth/role-guard";

export default function OperacionLayout() {
  return <RoleGuard rolesPermitidos={["owner", "waitress"]} />;
}
