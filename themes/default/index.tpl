{literal}
<div class="telephony-dashboard-wrapper antialiased bg-gray-100 text-gray-900 font-sans min-h-screen">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.3.0/flowbite.min.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.3.0/flowbite.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/alpinejs@3.13.3/dist/cdn.min.js" defer></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        primary: {"50":"#eff6ff","100":"#dbeafe","200":"#bfdbfe","300":"#93c5fd","400":"#60a5fa","500":"#3b82f6","600":"#2563eb","700":"#1d4ed8","800":"#1e40af","900":"#1e3a8a","950":"#172554"}
                    }
                }
            }
        }
    </script>
    
    <div x-data="telephonyDashboard()" x-init="init()" class="p-4 sm:p-4 lg:p-6 w-full mx-auto max-w-full">
        
        <!-- Offline Banner -->
        <div x-show="error" style="display: none;" class="mb-4 bg-red-600 rounded shadow-lg p-3 flex items-center justify-between text-white">
            <div class="flex items-center space-x-3">
                <svg class="w-6 h-6 animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>
                <span class="font-semibold">Conexão Perdida! Falha ao sincronizar com o Issabel. Tentando reconectar...</span>
            </div>
        </div>

        <!-- Header Global Tools -->
        <header class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 relative">
            <div>
                <h1 class="text-2xl font-bold text-gray-900 tracking-tight">Supervisão Operacional de Contact Center</h1>
                <p class="text-sm font-medium text-gray-500 flex items-center mt-1">
                    <span class="flex h-2 w-2 relative mr-2">
                      <span x-show="bgLoading && !error" class="animate-ping absolute inline-flex h-full w-full rounded-full bg-blue-400 opacity-75"></span>
                      <span class="relative inline-flex rounded-full h-2 w-2" :class="error ? 'bg-red-500' : (bgLoading ? 'bg-blue-500' : 'bg-emerald-500')"></span>
                    </span>
                    <span x-text="error ? 'Desconectado' : (bgLoading ? 'Sincronizando...' : 'Rodando em Tempo Real')"></span>
                </p>
            </div>
            <div class="flex items-center space-x-3 mt-3 md:mt-0">
                <button @click="refreshData()" class="px-3 py-1.5 text-sm font-semibold bg-white border border-gray-300 rounded shadow-sm hover:bg-gray-50 transition-colors flex items-center">
                    <svg class="w-4 h-4 mr-1 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path></svg>
                    Sync Manual
                </button>
            </div>
        </header>

        <!-- Skeleton Loading -->
        <div x-show="loading && !initialized" class="space-y-6">
            <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
                <template x-for="i in 5">
                    <div class="bg-white rounded border border-gray-200 p-4 h-24 animate-pulse"></div>
                </template>
            </div>
            <div class="h-64 bg-white rounded border animate-pulse"></div>
            <div class="h-96 bg-white rounded border animate-pulse"></div>
        </div>

        <div x-show="initialized" style="display: none;" class="space-y-4">
            <!-- KPIs Visão Geral -->
            <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-4 shadow-sm">
                <div class="bg-white rounded border border-gray-200 p-4 relative overflow-hidden">
                    <div class="absolute right-0 top-0 w-1 bg-blue-500 h-full"></div>
                    <h3 class="text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-1">Total de Chamadas</h3>
                    <p class="text-3xl font-mono font-bold text-gray-900" x-text="overview.today_calls"></p>
                </div>
                <div class="bg-white rounded border border-gray-200 p-4 relative overflow-hidden">
                    <div class="absolute right-0 top-0 w-1 bg-emerald-500 h-full"></div>
                    <h3 class="text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-1">Atendidas</h3>
                    <p class="text-3xl font-mono font-bold text-emerald-600" x-text="overview.answered_calls"></p>
                </div>
                <div class="bg-white rounded border-gray-200 p-4 relative overflow-hidden" :class="overview.abandoned_calls > 0 ? 'bg-red-50 border-red-200' : 'border'">
                    <div class="absolute right-0 top-0 w-1 h-full" :class="overview.abandoned_calls > 0 ? 'bg-red-600' : 'bg-gray-300'"></div>
                    <h3 class="text-[10px] font-bold uppercase tracking-wider mb-1" :class="overview.abandoned_calls > 0 ? 'text-red-800' : 'text-gray-400'">Perdidas / Abandonos</h3>
                    <p class="text-3xl font-mono font-bold">
                        <span class="text-gray-600" x-text="overview.missed_calls"></span> 
                        <span class="text-gray-300 font-sans mx-1">/</span> 
                        <span :class="overview.abandoned_calls > 0 ? 'text-red-600 animate-pulse' : 'text-gray-500'" x-text="overview.abandoned_calls"></span>
                    </p>
                </div>
                <div class="bg-white rounded border border-gray-200 p-4 relative overflow-hidden">
                    <div class="absolute right-0 top-0 w-1 bg-purple-500 h-full"></div>
                    <h3 class="text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-1">TME / TMA (Globais)</h3>
                    <p class="text-2xl font-mono font-bold text-gray-800 tracking-tighter">
                        <span :class="parseTime(overview.avg_wait_time) > 60 ? 'text-red-500' : ''" x-text="stripTime(overview.avg_wait_time)"></span>
                        <span class="text-gray-300 font-sans text-xl mx-0">/</span>
                        <span class="text-gray-500" x-text="stripTime(overview.avg_talk_time)"></span>
                    </p>
                </div>
                <div class="bg-white rounded border border-gray-200 p-4 relative overflow-hidden">
                    <div class="absolute right-0 top-0 w-1 bg-amber-500 h-full"></div>
                    <h3 class="text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-1">Agentes / Trunks</h3>
                    <p class="text-3xl font-mono font-bold text-gray-900">
                        <span x-text="overview.logged_agents"></span>
                        <span class="text-gray-300 font-sans text-xl mx-0">/</span>
                        <span class="text-emerald-600" x-text="overview.registered_peers"></span>
                    </p>
                </div>
            </div>

            <!-- Filas Ativas e Chamadas Superiores -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                <!-- Métricas Fila (Analítico Expandido) -->
                <div class="bg-white rounded border border-gray-200 shadow-sm overflow-hidden flex flex-col">
                    <div class="px-4 py-2 border-b border-gray-200 bg-gray-50 flex justify-between items-center flex-shrink-0">
                        <h2 class="font-bold text-gray-800 uppercase text-xs">Desempenho de Filas</h2>
                    </div>
                    <div class="overflow-x-auto flex-grow">
                        <table class="w-full text-xs text-left text-gray-600">
                            <thead class="text-[10px] text-gray-500 uppercase bg-gray-100/50 border-b border-gray-200">
                                <tr>
                                    <th class="px-3 py-2 font-bold w-1/4">Fila</th>
                                    <th class="px-3 py-2 font-bold text-center">Espera</th>
                                    <th class="px-3 py-2 font-bold text-center">Max. Wait</th>
                                    <th class="px-3 py-2 font-bold text-center">Atend / Aband</th>
                                    <th class="px-3 py-2 font-bold text-center w-1/5">SLA / NVL</th>
                                </tr>
                            </thead>
                            <tbody>
                                <template x-for="(q, index) in sortedQueues" :key="index">
                                    <tr class="border-b last:border-b-0 hover:bg-gray-50" :class="q.waiting > 0 ? 'bg-amber-50/20' : ''">
                                        <td class="px-3 py-2 font-bold text-sm text-gray-900">
                                            <span x-text="q.name"></span>
                                            <div class="text-[10px] text-gray-400 mt-1 uppercase" x-text="q.available + ' livres | ' + q.busy + ' ocupados'"></div>
                                        </td>
                                        <td class="px-3 py-2 font-mono text-center">
                                            <span class="px-1.5 py-0.5 rounded font-bold" :class="q.waiting > 0 ? 'bg-red-100 text-red-700 animate-pulse' : 'text-gray-400'" x-text="q.waiting"></span>
                                        </td>
                                        <td class="px-3 py-2 font-mono text-center font-bold" :class="parseTime(q.max_wait) > 120 ? 'text-red-500' : 'text-gray-500'" x-text="q.max_wait"></td>
                                        <td class="px-3 py-2 font-mono text-center font-bold">
                                            <span class="text-emerald-600" x-text="q.answered"></span> <span class="text-gray-300">/</span> <span class="text-red-500" x-text="q.abandoned"></span>
                                            <div class="text-[9px] text-gray-400 mt-0.5 tracking-tighter" x-show="parseInt(q.answered) + parseInt(q.abandoned) > 0">
                                                <span x-text="Math.round(parseInt(q.abandoned) / (parseInt(q.answered) + parseInt(q.abandoned)) * 100) + '% taxa abandono'"></span>
                                            </div>
                                        </td>
                                        <td class="px-3 py-2">
                                            <div class="flex items-center space-x-1">
                                                <span class="font-mono text-xs font-bold" :class="isSlaCritical(q.sla) ? 'text-red-600' : 'text-emerald-600'" x-text="q.sla"></span>
                                            </div>
                                            <div class="w-full bg-gray-200 rounded-full h-1 mt-1">
                                                <div class="h-1 rounded-full" :class="isSlaCritical(q.sla) ? 'bg-red-500' : 'bg-emerald-500'" :style="'width: ' + q.sla"></div>
                                            </div>
                                        </td>
                                    </tr>
                                </template>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Chamadas Ativas -->
                <div class="bg-white rounded border border-gray-200 shadow-sm overflow-hidden flex flex-col">
                    <div class="px-4 py-2 border-b border-gray-200 bg-gray-50 flex justify-between items-center flex-shrink-0">
                        <h2 class="font-bold text-gray-800 uppercase text-xs flex items-center">
                            <span class="w-2 h-2 rounded-full mr-2" :class="active_calls.length > 0 ? 'bg-emerald-500 animate-pulse' : 'bg-gray-300'"></span>
                            Log de Chamadas Ativas
                        </h2>
                    </div>
                    <div class="overflow-x-auto max-h-[300px] overflow-y-auto flex-grow">
                        <table class="w-full text-xs text-left text-gray-600">
                            <thead class="text-[10px] text-gray-500 uppercase bg-gray-100/50 sticky top-0 border-b">
                                <tr>
                                    <th class="px-3 py-2 font-bold">Duração / Status</th>
                                    <th class="px-3 py-2 font-bold">Fila</th>
                                    <th class="px-3 py-2 font-bold">Orig -> Dest</th>
                                    <th class="px-3 py-2 font-bold">Agente</th>
                                </tr>
                            </thead>
                            <tbody>
                                <template x-for="(call, index) in sortedCalls" :key="index">
                                    <tr class="border-b last:border-b-0 hover:bg-gray-50 bg-white">
                                        <td class="px-3 py-2 font-mono">
                                            <div class="font-bold text-sm" :class="parseTime(call.duration) > 300 ? 'text-red-500' : 'text-gray-800'" x-text="call.duration"></div>
                                            <span class="text-[9px] font-bold uppercase rounded" :class="call.status === 'Falando' ? 'text-emerald-600' : 'text-amber-600'" x-text="call.status"></span>
                                        </td>
                                        <td class="px-3 py-2 font-semibold text-gray-800" x-text="call.queue"></td>
                                        <td class="px-3 py-2 font-mono text-gray-800" x-text="call.source + ' -> ' + call.dest"></td>
                                        <td class="px-3 py-2 font-semibold" x-text="call.agent || '-'"></td>
                                    </tr>
                                </template>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- RANKING E OPERACIONAL DE AGENTES (Fase 4 - Nova Seção Full Width) -->
            <div class="bg-white rounded border border-gray-200 shadow-sm overflow-hidden flex flex-col">
                <div class="px-4 py-3 border-b border-gray-200 bg-gray-800 flex justify-between items-center text-white flex-shrink-0">
                    <div>
                        <h2 class="font-bold uppercase tracking-wider text-sm flex items-center">
                            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>
                            Operacional de Agentes
                        </h2>
                        <span class="text-xs text-gray-400 font-medium">Aderência, volume e identificação de anomalias operacionais (Short-calls e TMA)</span>
                    </div>
                    <div class="relative w-64">
                        <div class="absolute inset-y-0 left-0 flex items-center pl-2 pointer-events-none">
                            <svg class="w-4 h-4 text-gray-400" fill="none" viewBox="0 0 20 20" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z"/></svg>
                        </div>
                        <input type="search" x-model="searchAgent" class="block w-full p-1.5 pl-8 text-xs text-gray-100 bg-gray-700 border border-gray-600 rounded focus:ring-blue-500 focus:border-blue-500 placeholder-gray-400" placeholder="Filtrar Agentes...">
                    </div>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-sm text-left text-gray-600">
                        <thead class="text-[10px] text-gray-500 uppercase bg-gray-100/50 border-b border-gray-200">
                            <tr>
                                <th class="px-4 py-3 font-bold">Agente / Ramal</th>
                                <th class="px-4 py-3 font-bold text-center">Status</th>
                                <th class="px-4 py-3 font-bold text-center" title="Chamadas atendidas hoje">Atend.</th>
                                <th class="px-4 py-3 font-bold text-center" title="Chamadas menores que 15s (anomalia operativa)>">Short-Calls</th>
                                <th class="px-4 py-3 font-bold text-center" title="Tempo Médio de Atendimento">TMA</th>
                                <th class="px-4 py-3 font-bold text-center" title="Tempo Total Falado">Tempo Falado</th>
                                <th class="px-4 py-3 font-bold text-center" title="Aproximação de uso do agente em chamada vs pausa/idle">Ocupação (Est.)</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                            <template x-for="(a, i) in sortedFilteredAgents" :key="i">
                                <tr class="hover:bg-gray-50 transition-colors" :class="getAgentSuspectLevel(a) === 'suspeito' ? 'bg-red-50/30' : (getAgentSuspectLevel(a) === 'atencao' ? 'bg-amber-50/10' : 'bg-white')">
                                    <td class="px-4 py-3">
                                        <div class="font-bold text-gray-900 flex items-center">
                                            <span x-text="a.name" class="mr-2"></span>
                                            <template x-if="getAgentSuspectLevel(a) === 'suspeito'">
                                                <span class="px-1.5 py-0.5 bg-red-100 text-red-800 text-[9px] uppercase tracking-wider font-bold rounded border border-red-200 cursor-help animate-pulse" 
                                                      :title="'🚨 COMPORTAMENTO SUSPEITO! Taxa altíssima de queda. Streak Máx Curtas: ' + a.max_short_streak">SUSPEITO</span>
                                            </template>
                                            <template x-if="getAgentSuspectLevel(a) === 'atencao'">
                                                <span class="px-1.5 py-0.5 bg-amber-100 text-amber-800 text-[9px] uppercase tracking-wider font-bold rounded border border-amber-200 cursor-help" 
                                                      :title="'⚠️ ATENÇÃO: Sequência alta de short-calls recentes.'">ATENÇÃO</span>
                                            </template>
                                        </div>
                                        <div class="text-[10px] text-gray-500 font-mono mt-0.5" x-text="'Ramal ' + a.extension + ' • Fila: ' + a.queue"></div>
                                    </td>
                                    <td class="px-4 py-3 text-center">
                                        <span class="px-2 py-1 text-[10px] font-bold uppercase rounded-full shadow-sm" 
                                              :class="{ 'bg-emerald-100 text-emerald-800 border border-emerald-200': a.status === 'Livre', 'bg-amber-100 text-amber-800 border border-amber-200': a.status === 'Pausa', 'bg-red-100 text-red-800 border border-red-200': a.status === 'Em Chamada', 'bg-gray-100 text-gray-500': a.status === 'Offline' }" 
                                              x-text="a.status"></span>
                                    </td>
                                    <td class="px-4 py-3 text-center font-mono font-bold text-lg text-emerald-600" x-text="a.answered"></td>
                                    <td class="px-4 py-3 text-center">
                                        <div class="font-mono font-bold text-lg" :class="a.short_calls_pct > 15 ? 'text-red-600 animate-pulse' : 'text-gray-700'" x-text="a.short_calls"></div>
                                        <div class="text-[10px] font-bold mt-1" :class="a.short_calls_pct > 15 ? 'text-red-500 bg-red-100 px-1 rounded inline-block' : 'text-gray-400'" x-show="a.answered > 0" x-text="a.short_calls_pct + '% / Total'"></div>
                                    </td>
                                    <td class="px-4 py-3 text-center font-mono font-bold text-gray-700" x-text="stripTime(a.tma)"></td>
                                    <td class="px-4 py-3 text-center font-mono font-bold text-gray-700" x-text="stripTime(a.total_talk)"></td>
                                    <td class="px-4 py-3 text-center">
                                        <div class="font-mono font-bold" :class="parseInt(a.occupancy) > 85 ? 'text-amber-600' : 'text-gray-600'" x-text="a.occupancy"></div>
                                        <div class="text-[9px] text-gray-400">Tempo Falado</div>
                                    </td>
                                </tr>
                            </template>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Warning/Aviso sobre limitações -->
            <div class="text-xs text-gray-400 text-right mt-2 font-mono">
                * As métricas de Agentes utilizam cruzamento de logs (CDR x Core). Ocupação e tempo exato de pausa requerem auditoria local CEL ou CC-Agent do Issabel ativados.
            </div>

        </div>
    </div>
    
    <script>
        function telephonyDashboard() {
            return {
                initialized: false,
                loading: true,
                bgLoading: false,
                error: false,
                
                overview: {},
                queues: [],
                agents: [],
                active_calls: [],
                health: {},

                searchAgent: '',

                init() {
                    this.fetchData();
                    setInterval(() => {
                        if(this.initialized) this.bgLoading = true;
                        this.fetchData();
                    }, 5000);
                },

                get sortedQueues() {
                    return [...this.queues].sort((a, b) => {
                        if (b.waiting !== a.waiting) return b.waiting - a.waiting;
                        return parseFloat(a.sla) - parseFloat(b.sla);
                    });
                },

                get sortedCalls() {
                    return [...this.active_calls].sort((a,b) => {
                        return (b.duration || '').localeCompare((a.duration || ''));
                    });
                },

                get sortedFilteredAgents() {
                    let res = this.agents;
                    if(this.searchAgent) {
                        const q = this.searchAgent.toLowerCase();
                        res = res.filter(a => 
                            (a.name && a.name.toLowerCase().includes(q)) || 
                            (a.extension && a.extension.includes(q)) || 
                            (a.queue && a.queue.toLowerCase().includes(q)) || 
                            (a.status && a.status.toLowerCase().includes(q))
                        );
                    }
                    // Sort order: Agents Em Chamada first, then volume of shorts, then volume of calls
                    return res.sort((a,b) => {
                        if(a.status === 'Em Chamada' && b.status !== 'Em Chamada') return -1;
                        if(b.status === 'Em Chamada' && a.status !== 'Em Chamada') return 1;
                        if(b.short_calls !== a.short_calls) return b.short_calls - a.short_calls;
                        return b.answered - a.answered;
                    });
                },

                isSlaCritical(slaStr) {
                    let v = parseFloat(slaStr);
                    if (isNaN(v)) return false;
                    return v < 80;
                },

                getAgentSuspectLevel(agent) {
                    if (agent.answered < 3) return 'normal'; // Ignora amostragem muito baixa
                    
                    let score = 0;
                    if (agent.short_calls_pct > 30) score += 2;
                    else if (agent.short_calls_pct > 15) score += 1;

                    if (agent.current_short_streak >= 3 || agent.max_short_streak >= 4) score += 2;

                    // Média da fila
                    let filaTMA = 0;
                    let numAgentes = 0;
                    this.agents.forEach(a => {
                        if (a.queue === agent.queue && a.tma_sec > 0) {
                            filaTMA += a.tma_sec;
                            numAgentes++;
                        }
                    });
                    filaTMA = numAgentes > 0 ? filaTMA / numAgentes : 0;

                    if (filaTMA > 0 && agent.tma_sec > 0 && agent.tma_sec < (filaTMA * 0.4)) { // Menos que 40% da media da fila
                        score += 1;
                    }

                    if (score >= 3) return 'suspeito';
                    if (score >= 1) return 'atencao';
                    return 'normal';
                },

                parseTime(timeStr) {
                    if(!timeStr) return 0;
                    let parts = String(timeStr).split(':');
                    if(parts.length === 3) {
                        return parseInt(parts[0])*3600 + parseInt(parts[1])*60 + parseInt(parts[2]);
                    }
                    return 0;
                },

                stripTime(timeStr) {
                    if(!timeStr || timeStr === "--:--:--" || timeStr === "00:00:00") return "00:00";
                    return String(timeStr).replace(/^00:/, '');
                },

                async fetchData() {
                    try {
                        const res = await fetch('index.php?menu=telephony_dashboard&action=get_data&rawmode=yes');
                        if (!res.ok) throw new Error('Bad Network');
                        const data = await res.json();
                        
                        this.overview = data.overview;
                        this.queues = data.queues;
                        this.agents = data.agents;
                        this.active_calls = data.active_calls;
                        this.health = data.health;
                        
                        this.error = false;
                        this.initialized = true;
                        this.loading = false;
                        this.bgLoading = false;
                    } catch (e) {
                        this.error = true;
                        this.bgLoading = false;
                    }
                },
                
                refreshData() {
                    if(!this.initialized) this.loading = true;
                    this.bgLoading = true;
                    this.fetchData();
                }
            }
        }
    </script>
</div>
{/literal}
