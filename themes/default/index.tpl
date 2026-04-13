{literal}
<div class="telephony-dashboard-wrapper antialiased bg-gray-50 text-gray-900 font-sans min-h-screen">
    <!-- Dependências: Tailwind e Flowbite via CDN para evitar complexidade no build do Issabel -->
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.3.0/flowbite.min.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.3.0/flowbite.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/alpinejs@3.13.3/dist/cdn.min.js" defer></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <!-- Custom Tailwind Config -->
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
    
    <!-- AlpineJS App Scope -->
    <div x-data="telephonyDashboard()" x-init="init()" class="p-4 sm:p-6 lg:p-8 w-full">
        <!-- Header -->
        <header class="flex justify-between items-center mb-6">
            <div>
                <h1 class="text-2xl font-bold text-gray-900">Dashboard Operacional</h1>
                <p class="text-sm text-gray-500">Monitoramento de Telefonia em Tempo Real</p>
            </div>
            
            <div class="flex items-center space-x-3">
                <div class="text-sm flex items-center space-x-2 bg-white px-3 py-1 rounded-lg border border-gray-200 shadow-sm">
                    <span class="relative flex h-3 w-3">
                      <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" x-show="health.asterisk_status == 'Online'"></span>
                      <span class="relative inline-flex rounded-full h-3 w-3" :class="health.asterisk_status == 'Online' ? 'bg-emerald-500' : 'bg-red-500'"></span>
                    </span>
                    <span class="font-medium text-gray-700">Asterisk: <span x-text="health.asterisk_status"></span></span>
                </div>
                <button @click="refreshData()" class="p-2 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 shadow-sm transition-colors" title="Atualizar">
                    <svg class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path></svg>
                </button>
            </div>
        </header>

        <!-- Spinner Loading (Initial) -->
        <div x-show="loading && !initialized" class="flex justify-center items-center h-64">
            <div role="status">
                <svg aria-hidden="true" class="w-8 h-8 text-gray-200 animate-spin fill-primary-600" viewBox="0 0 100 101" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z" fill="currentColor"/><path d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z" fill="currentFill"/></svg>
                <span class="sr-only">Carregando...</span>
            </div>
        </div>

        <div x-show="initialized" x-cloak class="space-y-6">
            <!-- KPIs Visão Geral -->
            <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-4">
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 transition-all hover:shadow-md">
                    <div class="flex items-center justify-between mb-2">
                        <h3 class="text-sm font-medium text-gray-500">Chamadas Hoje</h3>
                        <div class="p-2 rounded-lg bg-blue-50 text-blue-600">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path></svg>
                        </div>
                    </div>
                    <p class="text-2xl font-bold text-gray-900" x-text="overview.today_calls"></p>
                </div>
                
                <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 transition-all hover:shadow-md">
                    <div class="flex items-center justify-between mb-2">
                        <h3 class="text-sm font-medium text-gray-500">Atendidas</h3>
                        <div class="p-2 rounded-lg bg-emerald-50 text-emerald-600">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                        </div>
                    </div>
                    <p class="text-2xl font-bold text-gray-900" x-text="overview.answered_calls"></p>
                </div>

                <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 transition-all hover:shadow-md">
                    <div class="flex items-center justify-between mb-2">
                        <h3 class="text-sm font-medium text-gray-500">Perdidas / Aband.</h3>
                        <div class="p-2 rounded-lg bg-red-50 text-red-600">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                        </div>
                    </div>
                    <p class="text-2xl font-bold text-gray-900"><span x-text="overview.missed_calls"></span> / <span x-text="overview.abandoned_calls" class="text-orange-500"></span></p>
                </div>

                <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 transition-all hover:shadow-md">
                    <div class="flex items-center justify-between mb-2">
                        <h3 class="text-sm font-medium text-gray-500">Tempo Méd. (TME/TMA)</h3>
                        <div class="p-2 rounded-lg bg-purple-50 text-purple-600">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        </div>
                    </div>
                    <p class="text-lg font-bold text-gray-900"><span x-text="overview.avg_wait_time"></span> / <span x-text="overview.avg_talk_time" class="text-gray-500"></span></p>
                </div>

                <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 transition-all hover:shadow-md">
                    <div class="flex items-center justify-between mb-2">
                        <h3 class="text-sm font-medium text-gray-500">Agentes / Ramais</h3>
                        <div class="p-2 rounded-lg bg-amber-50 text-amber-600">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path></svg>
                        </div>
                    </div>
                    <p class="text-xl font-bold text-gray-900"><span x-text="overview.logged_agents"></span> | <span x-text="overview.registered_peers" class="text-emerald-500"></span></p>
                </div>
            </div>

            <!-- Main Content Grid -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Painel de Filas & Chamadas -->
                <div class="lg:col-span-2 space-y-6">
                    <!-- Chamadas em Andamento -->
                    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                        <div class="px-5 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
                            <h2 class="font-semibold text-gray-900 flex items-center">
                                <span class="w-2 h-2 rounded-full bg-emerald-500 mr-2 animate-pulse"></span>
                                Chamadas Ativas
                            </h2>
                            <span class="bg-primary-100 text-primary-800 text-xs font-medium px-2.5 py-0.5 rounded-full" x-text="active_calls.length + ' Ativas'"></span>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full text-sm text-left text-gray-500">
                                <thead class="text-xs text-gray-700 uppercase bg-gray-50">
                                    <tr>
                                        <th scope="col" class="px-5 py-3 rounded-tl-lg">Origem / Destino</th>
                                        <th scope="col" class="px-5 py-3">Fila</th>
                                        <th scope="col" class="px-5 py-3">Agente</th>
                                        <th scope="col" class="px-5 py-3">Duração</th>
                                        <th scope="col" class="px-5 py-3">Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <template x-for="(call, index) in active_calls" :key="index">
                                        <tr class="bg-white border-b hover:bg-gray-50 transition-colors">
                                            <td class="px-5 py-3 font-medium text-gray-900">
                                                <div x-text="call.source"></div>
                                                <div class="text-xs text-gray-400">&rarr; <span x-text="call.dest"></span></div>
                                            </td>
                                            <td class="px-5 py-3" x-text="call.queue"></td>
                                            <td class="px-5 py-3" x-text="call.agent"></td>
                                            <td class="px-5 py-3 font-mono text-xs" x-text="call.duration"></td>
                                            <td class="px-5 py-3">
                                                <span class="px-2.5 py-1 text-xs font-medium rounded-full" 
                                                      :class="call.status === 'Falando' ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'"
                                                      x-text="call.status"></span>
                                            </td>
                                        </tr>
                                    </template>
                                    <tr x-show="active_calls.length === 0">
                                        <td colspan="5" class="px-5 py-8 text-center text-gray-400">Nenhuma chamada ativa no momento.</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Filas Ativas -->
                    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                        <div class="px-5 py-4 border-b border-gray-100 bg-gray-50/50">
                            <h2 class="font-semibold text-gray-900">Métricas de Fila</h2>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-0 divide-y md:divide-y-0 md:divide-x divide-gray-100">
                            <template x-for="(q, index) in queues" :key="index">
                                <div class="p-5">
                                    <div class="flex justify-between items-center mb-4">
                                        <h3 class="font-bold text-gray-800 text-lg" x-text="q.name"></h3>
                                        <span class="text-xs font-semibold px-2 py-1 bg-green-100 text-green-800 rounded" x-text="'SLA: ' + q.sla"></span>
                                    </div>
                                    <div class="grid grid-cols-2 gap-4">
                                        <div class="bg-gray-50 p-3 rounded-lg text-center border border-gray-100">
                                            <div class="text-2xl font-bold" :class="q.waiting > 0 ? 'text-red-500' : 'text-gray-900'" x-text="q.waiting"></div>
                                            <div class="text-xs text-gray-500 uppercase font-semibold mt-1">Em Espera</div>
                                        </div>
                                        <div class="bg-gray-50 p-3 rounded-lg text-center border border-gray-100">
                                            <div class="text-2xl font-bold text-gray-900" x-text="q.abandoned"></div>
                                            <div class="text-xs text-gray-500 uppercase font-semibold mt-1">Abandonos</div>
                                        </div>
                                        <div class="bg-emerald-50/50 p-3 rounded-lg text-center border border-emerald-100">
                                            <div class="text-xl font-bold text-emerald-700" x-text="q.available"></div>
                                            <div class="text-xs text-emerald-600 uppercase font-semibold mt-1">Livres</div>
                                        </div>
                                        <div class="bg-amber-50/50 p-3 rounded-lg text-center border border-amber-100">
                                            <div class="text-xl font-bold text-amber-700" x-text="q.busy"></div>
                                            <div class="text-xs text-amber-600 uppercase font-semibold mt-1">Ocupados</div>
                                        </div>
                                    </div>
                                </div>
                            </template>
                        </div>
                    </div>
                </div>

                <!-- Painel Lateral: Agentes e Eventos -->
                <div class="space-y-6">
                    <!-- Agentes Logados -->
                    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden h-96 flex flex-col">
                        <div class="px-5 py-4 border-b border-gray-100 bg-gray-50/50 flex flex-shrink-0 justify-between">
                            <h2 class="font-semibold text-gray-900">Status dos Agentes</h2>
                        </div>
                        <div class="p-4 overflow-y-auto flex-grow">
                            <div class="space-y-3">
                                <template x-for="(agent, i) in agents" :key="i">
                                    <div class="flex items-center justify-between p-3 rounded-lg border border-gray-100 hover:border-gray-200 hover:bg-gray-50 transition-colors">
                                        <div class="flex items-center space-x-3">
                                            <div class="flex-shrink-0 w-2 h-2 rounded-full" 
                                                 :class="{
                                                    'bg-emerald-500': agent.status === 'Livre',
                                                    'bg-amber-500': agent.status === 'Pausa',
                                                    'bg-red-500': agent.status === 'Em Chamada'
                                                 }"></div>
                                            <div>
                                                <p class="text-sm font-semibold text-gray-900" x-text="agent.name"></p>
                                                <p class="text-xs text-gray-500"><span x-text="agent.extension"></span> &bull; <span x-text="agent.queue"></span></p>
                                            </div>
                                        </div>
                                        <div class="text-right">
                                            <p class="text-xs font-semibold" 
                                               :class="{
                                                   'text-emerald-600': agent.status === 'Livre',
                                                   'text-amber-600': agent.status === 'Pausa',
                                                    'text-red-600': agent.status === 'Em Chamada'
                                               }" x-text="agent.status"></p>
                                            <p class="text-xs font-mono text-gray-400" x-text="agent.time_in_status"></p>
                                        </div>
                                    </div>
                                </template>
                            </div>
                        </div>
                    </div>

                    <!-- Eventos Recentes -->
                    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                        <div class="px-5 py-4 border-b border-gray-100 bg-gray-50/50">
                            <h2 class="font-semibold text-gray-900">Eventos Recentes</h2>
                        </div>
                        <div class="p-4">
                            <ol class="relative border-l border-gray-200 ml-3">                  
                                <template x-for="(ev, i) in recent_events" :key="i">
                                    <li class="mb-4 ml-4">
                                        <div class="absolute w-2 h-2 bg-gray-200 rounded-full mt-1.5 -left-1 border border-white"></div>
                                        <time class="mb-1 text-xs font-normal leading-none text-gray-400" x-text="ev.time"></time>
                                        <p class="text-sm text-gray-600" x-text="ev.event"></p>
                                    </li>
                                </template>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- AlpineJS Logic -->
    <script>
        function telephonyDashboard() {
            return {
                initialized: false,
                loading: true,
                overview: {},
                queues: [],
                agents: [],
                active_calls: [],
                recent_events: [],
                health: {},

                init() {
                    this.fetchData();
                    setInterval(() => {
                        this.fetchData();
                    }, 5000); // Poll a cada 5 segundos
                },

                async fetchData() {
                    try {
                        // O parâmetro rawmode=yes evita que a GUI do Issabel envolva o JSON com menus
                        const res = await fetch('index.php?menu=telephony_dashboard&action=get_data&rawmode=yes');
                        const data = await res.json();
                        
                        this.overview = data.overview;
                        this.queues = data.queues;
                        this.agents = data.agents;
                        this.active_calls = data.active_calls;
                        this.recent_events = data.recent_events;
                        this.health = data.health;
                        
                        this.initialized = true;
                        this.loading = false;
                    } catch (e) {
                        console.error('Falha ao obter dados do dashboard', e);
                    }
                },
                
                refreshData() {
                    this.loading = true;
                    this.fetchData();
                }
            }
        }
    </script>
</div>
{/literal}
