import { useState } from "react";
import { ChevronLeft, ChevronRight, ChevronDown } from "lucide-react";
import { cn } from "../constants/theme";

export const CustomCalendar = ({ 
  selectedDate, 
  onSelect, 
  onClose 
}: { 
  selectedDate: string; 
  onSelect: (date: string) => void; 
  onClose: () => void;
}) => {
  const [currentDate, setCurrentDate] = useState(selectedDate ? new Date(selectedDate) : new Date());

  const year = currentDate.getFullYear();
  const month = currentDate.getMonth();

  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const firstDayOfMonth = new Date(year, month, 1).getDay();

  const days = [];
  for (let i = 0; i < firstDayOfMonth; i++) {
    days.push(null);
  }
  for (let i = 1; i <= daysInMonth; i++) {
    days.push(i);
  }

  const handlePrevMonth = () => setCurrentDate(new Date(year, month - 1, 1));
  const handleNextMonth = () => setCurrentDate(new Date(year, month + 1, 1));

  const handleSelect = (day: number) => {
    const m = String(month + 1).padStart(2, '0');
    const d = String(day).padStart(2, '0');
    onSelect(`${year}-${m}-${d}`);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm" onClick={onClose}>
      <div className="bg-[#142024] border border-white/10 rounded-2xl p-5 w-full max-w-sm shadow-2xl" onClick={e => e.stopPropagation()}>
        {/* Header */}
        <div className="flex justify-between items-center mb-6">
          <button onClick={handlePrevMonth} className="p-2 text-slate-400 hover:text-white rounded-full hover:bg-white/5 transition-colors">
            <ChevronLeft size={20}/>
          </button>
          <div className="flex items-center gap-3">
            <div className="relative flex items-center">
              <select 
                value={year} 
                onChange={(e) => setCurrentDate(new Date(parseInt(e.target.value), month, 1))}
                className="bg-transparent text-white font-bold text-lg appearance-none cursor-pointer outline-none pr-4 z-10"
              >
                {Array.from({length: 10}, (_, i) => new Date().getFullYear() - 5 + i).map(y => (
                  <option key={y} value={y} className="bg-[#142024] text-white text-base">{y}年</option>
                ))}
              </select>
              <ChevronDown size={16} className="text-slate-400 absolute right-0 pointer-events-none" />
            </div>
            <div className="relative flex items-center">
              <select 
                value={month} 
                onChange={(e) => setCurrentDate(new Date(year, parseInt(e.target.value), 1))}
                className="bg-transparent text-white font-bold text-lg appearance-none cursor-pointer outline-none pr-4 z-10"
              >
                {Array.from({length: 12}, (_, i) => i).map(m => (
                  <option key={m} value={m} className="bg-[#142024] text-white text-base">{m + 1}月</option>
                ))}
              </select>
              <ChevronDown size={16} className="text-slate-400 absolute right-0 pointer-events-none" />
            </div>
          </div>
          <button onClick={handleNextMonth} className="p-2 text-slate-400 hover:text-white rounded-full hover:bg-white/5 transition-colors">
            <ChevronRight size={20}/>
          </button>
        </div>
        {/* Weekdays */}
        <div className="grid grid-cols-7 gap-1 mb-2">
          {['日', '一', '二', '三', '四', '五', '六'].map(d => (
            <div key={d} className="text-center text-xs text-slate-500 font-medium py-1">{d}</div>
          ))}
        </div>
        {/* Days */}
        <div className="grid grid-cols-7 gap-1">
          {days.map((day, idx) => {
            if (!day) return <div key={`empty-${idx}`} className="p-2"></div>;
            const dateStr = `${year}-${String(month + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
            const isSelected = dateStr === selectedDate;
            return (
              <button
                key={idx}
                onClick={() => handleSelect(day)}
                className={cn(
                  "p-2 text-sm rounded-full flex items-center justify-center aspect-square transition-all",
                  isSelected 
                    ? "bg-primary text-background-dark font-bold shadow-[0_0_15px_rgba(17,164,212,0.4)]" 
                    : "text-slate-300 hover:bg-white/10 hover:text-white"
                )}
              >
                {day}
              </button>
            );
          })}
        </div>
        <div className="mt-6 flex justify-end">
          <button onClick={onClose} className="text-sm font-bold text-slate-400 hover:text-white px-4 py-2 rounded-full hover:bg-white/5 transition-colors">取消</button>
        </div>
      </div>
    </div>
  );
};
