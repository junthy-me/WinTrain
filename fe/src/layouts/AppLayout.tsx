import { Outlet } from "react-router-dom";
import { BottomNav } from "../components/BottomNav";

export function AppLayout() {
  return (
    <div className="min-h-screen bg-black flex justify-center">
      {/* Mobile container simulation */}
      <div className="w-full max-w-md bg-background-dark min-h-screen relative shadow-2xl overflow-x-hidden flex flex-col border-x border-white/5">
        <div className="flex-1 pb-24">
          <Outlet />
        </div>
        <BottomNav />
      </div>
    </div>
  );
}
