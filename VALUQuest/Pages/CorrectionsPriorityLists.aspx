<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="CorrectionsPriorityLists.aspx.cs" Inherits="VALUQuest.Pages.CorrectionsPriorityLists" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <!-- <link href="https://unpkg.com/@hyper-ui/core@1.2.3/dist/hyper.min.css" rel="stylesheet" /> -->
    <script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js"></script>


    <style>
        :root {
            --ct-font-sans-serif: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
            overflow: hidden;
            font-family: var(--ct-font-sans-serif);
        }

        .container {
          display: flex;
          flex-direction: row;
            height: 100vh; /* tutta altezza viewport */
          width: 100%;
          gap: 0;
          box-sizing: border-box;
          overflow: hidden; /* importantissimo: niente scroll qui */
        }

        .left, .right {
          width: 50%;
          display: flex;
          flex-direction: column;
          border-right: 1px solid #ccc;
          overflow-y: auto;  /* scroll verticale */
          overflow-x: hidden; /* evita scroll orizzontale */
          padding: 0.75rem;
          background: white;
            height: 100vh; /* altezza totale viewport */
        }

        #listsContainer, #allItems {
            flex-grow: 1;
            overflow-y: auto;
            min-height: 0; /* essenziale per scroll corretto */
        }


        .list-title {
            font-weight: bold;
            margin-bottom: 0.5rem;
            text-transform: uppercase;
            font-size: 1.1rem;
        }

        .priority-list {
            border: 2px solid #008080;
            border-radius: 8px;
            padding: 0.8rem;
            margin-bottom: 1.5rem;
            background-color: #eefdfd;
        }

        .priority-rows {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .priority-row {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            background: #f4f4f4;
            border: 1px dashed #aaa;
            border-radius: 6px;
            padding: 0.5rem;
        }

        .row-line {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .item {
            padding: 0.4rem 0.6rem;
            background: #fff;
            border: 1px solid #999;
            border-radius: 4px;
            display: flex;
            align-items: center;
            gap: 0.3rem;
            cursor: grab;
            min-width: 100px;
        }

        .item .delete-btn {
            color: red;
            font-weight: bold;
            cursor: pointer;
            border: 1px solid red;
            border-radius: 4px;
            padding: 0 5px;
        }

        .remove-list {
            float: right;
            background: none;
            border: 2px solid red;
            color: red;
            padding: 2px 6px;
            font-weight: bold;
            border-radius: 4px;
            cursor: pointer;
        }

        .add-row-btn {
            margin-top: 0.5rem;
            font-size: 0.85rem;
        }

        .create-btn {
            margin-bottom: 1rem;
        }

        .connector-select {
            padding: 0.3rem;
            border: 1px solid #aaa;
            border-radius: 4px;
            background: #eee;
            font-weight: bold;
        }

        .priority-list.collapsed .priority-rows {
            display: none;
        }
        .priority-list {
            background-color: #fff;
            border-left: 4px solid transparent;
        }

        .priority-list.active {
            border-left-color: #198754;
        }

        .priority-list.inactive {
            border-left-color: #dc3545;
        }

        .priority-list.draft {
            border: 2px solid #3399ff;
            background-color: #e6f4ff;
        }.new-list-highlight {
            border: 2px solid #3399ff !important;
            background-color: #e6f4ff !important;
            transition: background-color 1s, border 1s;
        }
        .form-switch {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.9rem;
            font-weight: 500;
        }
        .form-switch input[type="checkbox"] {
            display: none;
        }
        .form-switch i {
            width: 40px;
            height: 22px;
            background: #ccc;
            border-radius: 12px;
            position: relative;
            cursor: pointer;
            transition: background 0.3s;
        }
        .form-switch i::after {
            content: '';
            position: absolute;
            width: 18px;
            height: 18px;
            top: 2px;
            left: 2px;
            border-radius: 50%;
            background: #fff;
            transition: transform 0.3s;
        }
        .form-switch input:checked + i {
            background: #28a745;
        }
        .form-switch input:checked + i::after {
            transform: translateX(18px);
        }

    </style>

    <form id="form1" runat="server">
        <div class="container">
            <div class="left d-flex flex-column position-relative">
            <div class="position-sticky top-0 bg-white pb-2 z-1">
                <button type="button" class="btn btn-success btn-sm w-100" onclick="createList()">
                <i class="fas fa-plus me-1"></i> Nuova lista
                </button>
            </div>
            <div id="listsContainer" class="flex-grow-1 overflow-auto mt-2"></div>
            </div>

            <div class="right d-flex flex-column">
            <div class="list-title mb-2">Lista Correzioni</div>
            <div id="allItems" class="priority-row flex-grow-1 overflow-auto"></div>
            </div>
        </div>

        <asp:HiddenField ID="hiddenJsonData" runat="server" />
    </form>

    <script>

        let listCounter = 1;

        function loadCorrections() {
            return fetch('CorrectionsPriorityLists.aspx/getCorrectionsWithConditions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            })
                .then(res => res.json())
                .then(res => {
                    let items = res.d;
                    if (typeof items === 'string') items = JSON.parse(items);
                    if (!Array.isArray(items)) items = [items];

                    const container = document.getElementById('allItems');
                    container.innerHTML = '';

                    items.forEach(corr => {
                        const div = document.createElement('div');
                        div.className = 'item';
                        div.setAttribute('draggable', 'true');
                        div.setAttribute('data-id', corr.correctionId);
                        div.setAttribute('title', corr.message || corr.notes || '');

                        const valueFormatted = `${corr.valueToAdd > 0 ? '+' : ''}${corr.valueToAdd}`;
                        const valueColor = corr.valueToAdd > 0 ? 'green' : (corr.valueToAdd < 0 ? 'red' : 'black');
                        //div.innerHTML = `${corr.correctionName} <span style="color:${valueColor}; font-weight:bold;">(${valueFormatted})</span>`;
                        div.innerHTML = formatCorrectionDisplay(corr.correctionId, corr.correctionName, corr.valueToAdd);

                        container.appendChild(div);
                    });

                    new Sortable(container, {
                        group: { name: 'shared', pull: 'clone', put: false },
                        animation: 150,
                        sort: false
                    });
                })
                .catch(err => {
                    console.error("❌ Errore caricamento correzioni:", err);
                });
        }

        function loadSavedLists() {
            fetch('CorrectionsPriorityLists.aspx/LoadAllPriorityLists', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            })
                .then(res => res.json())
                .then(res => {
                    const lists = res.d || [];
                    console.log("Liste ricevute:", lists);

                    lists.forEach(list => {
                        createListFromDB(list);
                    });
                })
                .catch(err => console.error("Errore caricamento liste:", err));
        }
        function createListFromDB(list) {
            const listId = `priority-${list.ListId}`;
            const wrapper = document.createElement('div');
            const statusClass = list.IsActive ? 'active' : 'inactive';
            wrapper.className = `priority-list ${statusClass}`;
            wrapper.setAttribute('data-listid', list.ListId);

            wrapper.innerHTML = `
                  <div class="list-title d-flex align-items-center justify-content-between mb-2" onclick="toggleList(this)" style="cursor: pointer;" title="Collapse">
                    <div class="d-flex align-items-center gap-2">
                      <button type="button" class="arrow btn btn-outline-primary btn-sm d-flex align-items-center justify-content-center"
                            style="width: 28px; height: 28px; font-weight: bold; padding: 0; margin-right: 5px;"> ＋</button>
                            <span class="editable-title fw-semibold" ondblclick="toggleTitleEdit(this)">${list.ListName}</span>
                      <input type="text" class="title-input form-control form-control-sm" style="display:none; width: auto; max-width: 300px;" onblur="confirmTitleEdit(this)" />
                    </div>
                    <button class="remove-list btn btn-sm btn-danger ms-2" onclick="event.stopPropagation(); confirmDeleteList(this)">
                      <i class="fas fa-times"></i>
                    </button>
                  </div>

                  <div class="priority-rows" id="${listId}" style="display: none;"></div>

                  <div class="d-flex justify-content-between align-items-center mt-3">
                    <div class="d-flex gap-2">
                      <button type="button" class="btn btn-outline-primary btn-sm" onclick="addRow('${listId}')">
                        <i class="fas fa-plus me-1"></i> Nuovo elemento
                      </button>
                      <button type="button" class="btn btn-primary btn-sm" onclick="saveSingleList(this)">
                        <i class="fas fa-save me-1"></i> Salva lista
                      </button>
                    </div>

                    <div class="form-check form-switch ms-auto">
                    <label class="form-switch ms-3">
                        <input type="checkbox" class="list-status-toggle" onchange="updateListStatus(this)">
                        <i></i> <span class="status-label">Attiva</span>
                    </label>
                    </div>
                  </div>`;



            document.getElementById('listsContainer').appendChild(wrapper);

            // ✅ Imposta attivo/disattivo visivamente nel toggle
            setTimeout(() => {
                const toggle = wrapper.querySelector('.list-status-toggle');
                const label = wrapper.querySelector('.status-label');
                if (toggle && label) {
                    toggle.checked = list.IsActive === true || list.IsActive === 1 || list.IsActive === "1";
                    updateListStatus(toggle); // aggiorna classe e testo
                }
            }, 0);

            // ✅ Inserisci le righe e correzioni
            const rowContainer = wrapper.querySelector('.priority-rows');

            list.Rows.forEach(row => {
                const rowDiv = document.createElement('div');
                rowDiv.className = 'priority-row';

                row.Corrections.forEach((corr, index) => {
                    const line = document.createElement('div');
                    line.className = 'row-line';

                    const itemDiv = document.createElement('div');
                    itemDiv.className = 'item';
                    itemDiv.setAttribute('data-id', corr.CorrectionId);
                    const valueToAdd = corr.ValueToAdd ?? 0;
                    //itemDiv.textContent = `${corr.CorrectionId} - ${corr.CorrectionName} (${valueToAdd > 0 ? '+' : ''}${valueToAdd})`;
                    itemDiv.innerHTML = formatCorrectionDisplay(corr.CorrectionId, corr.CorrectionName, valueToAdd);

                    const delBtn = document.createElement('span');
                    delBtn.textContent = 'X';
                    delBtn.className = 'delete-btn';
                    delBtn.onclick = () => {
                        line.remove();
                        updateRow(rowDiv);
                    };

                    itemDiv.appendChild(delBtn);
                    line.appendChild(itemDiv);

                    if (index < row.Corrections.length - 1) {
                        const connector = document.createElement('select');
                        connector.className = 'connector-select';
                        connector.innerHTML = `
                                <option value="AND" ${corr.ConnectorToNext === 'AND' ? 'selected' : ''}>AND</option>
                                <option value="OR" ${corr.ConnectorToNext === 'OR' ? 'selected' : ''}>OR</option>
                            `;
                        line.appendChild(connector);
                    }

                    rowDiv.appendChild(line);
                });

                rowContainer.appendChild(rowDiv);
                new Sortable(rowDiv, {
                    group: 'shared',
                    animation: 150,
                    sort: true,
                    onAdd: evt => {
                        const clone = evt.item.cloneNode(true);
                        evt.item.remove();
                        clone.querySelectorAll('.delete-btn').forEach(btn => btn.remove());

                        const delBtn = document.createElement('span');
                        delBtn.textContent = 'X';
                        delBtn.className = 'delete-btn';
                        delBtn.onclick = () => {
                            line.remove();
                            updateRow(rowDiv);
                        };

                        const corrId = clone.getAttribute('data-id');
                        const name = clone.textContent.trim();
                        const valueMatch = name.match(/\(([-+0-9.,]+)\)/);
                        const value = valueMatch ? parseFloat(valueMatch[1]) : 0;
                        const label = name.replace(/\s*\([-+0-9.,]+\)$/, '').replace(/^\d+\s*-\s*/, '');

                        clone.innerHTML = formatCorrectionDisplay(corrId, label, value);

                        clone.appendChild(delBtn);

                        const line = document.createElement('div');
                        line.className = 'row-line';
                        line.appendChild(clone);
                        rowDiv.appendChild(line);

                        updateRow(rowDiv);
                    },
                    onUpdate: () => updateRow(rowDiv),
                    onRemove: () => updateRow(rowDiv)
                });

                updateRow(rowDiv); // aggiorna i connettori
            });
        }

        function createList() {
            const listId = `priority-${listCounter}`;
            const wrapper = document.createElement('div');
            wrapper.className = 'priority-list active';
            wrapper.classList.add('new-list-highlight');
            wrapper.scrollIntoView({ behavior: 'smooth', block: 'center' });

            wrapper.innerHTML = `
                  <div class="list-title d-flex align-items-center justify-content-between mb-2" onclick="toggleList(this)" style="cursor: pointer;" title="Collapse">
                    <div class="d-flex align-items-center gap-2">
                      <button type="button" class="arrow btn btn-outline-primary btn-sm d-flex align-items-center justify-content-center"
                              style="width: 28px; height: 28px; font-weight: bold; padding: 0; margin-right: 5px;">−</button>
                      <span class="editable-title fw-semibold" ondblclick="toggleTitleEdit(this)">PRIORITY LIST ${listCounter}</span>
                      <input type="text" class="title-input form-control form-control-sm"
                             style="display:none; width: auto; max-width: 300px;" onblur="confirmTitleEdit(this)" />
                    </div>
                    <button class="remove-list btn btn-sm btn-danger ms-2" onclick="event.stopPropagation(); confirmDeleteList(this)">
                      <i class="fas fa-times"></i>
                    </button>
                  </div>

                  <div class="priority-rows" id="${listId}" style="display: flex;"></div>

                  <div class="d-flex justify-content-between align-items-center mt-3">
                    <div class="d-flex gap-2">
                      <button type="button" class="btn btn-outline-primary btn-sm" onclick="addRow('${listId}')">
                        <i class="fas fa-plus me-1"></i> Nuovo elemento
                      </button>
                      <button type="button" class="btn btn-primary btn-sm" onclick="saveSingleList(this)">
                        <i class="fas fa-save me-1"></i> Salva lista
                      </button>
                    </div>

                    <div class="form-check form-switch ms-auto">
                      <label class="form-switch ms-3">
                        <input type="checkbox" class="list-status-toggle" onchange="updateListStatus(this)" checked>
                        <i></i> <span class="status-label">Attiva</span>
                      </label>
                    </div>
                  </div>
                `;

            wrapper.setAttribute('data-listid', '');
            wrapper.classList.add('priority-list', 'active', 'new-list-highlight');

            document.getElementById('listsContainer').appendChild(wrapper);
            addRow(listId);
            listCounter++;
        }

        function toggleList(header) {
            const listContainer = header.closest('.priority-list');
            const rows = listContainer.querySelector('.priority-rows');
            const arrow = header.querySelector('.arrow');

            const isCollapsed = rows.style.display === 'none';

            if (isCollapsed) {
                rows.style.display = 'flex';
                arrow.textContent = '−';
                header.title = 'Collapse';
            } else {
                rows.style.display = 'none';
                arrow.textContent = '＋';
                header.title = 'Expand';
            }
        }

        function toggleListStatus(button) {
            const list = button.closest('.priority-list');
            const isActive = list.classList.contains('active');

            if (isActive) {
                list.classList.remove('active');
                list.classList.add('inactive');
                button.textContent = 'Attiva';
            } else {
                list.classList.remove('inactive');
                list.classList.add('active');
                button.textContent = 'Disattiva';
            }
        }

        function toggleTitleEdit(span) {
            const input = span.nextElementSibling;
            input.value = span.textContent.trim();
            span.style.display = 'none';
            input.style.display = 'inline-block';
            input.focus();
        }

        function confirmTitleEdit(input) {
            const span = input.previousElementSibling;
            span.textContent = input.value.trim() || "Senza nome";
            input.style.display = 'none';
            span.style.display = 'inline-block';
        }

        function confirmDeleteList(button) {
            if (!confirm("Confermi di eliminare questa lista?")) return;

            const listElem = button.closest('.priority-list');
            const listIdAttr = listElem.getAttribute('data-listid');

            if (listIdAttr) {
                fetch('CorrectionsPriorityLists.aspx/DeleteList', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ listId: parseInt(listIdAttr) })
                })
                    .then(res => res.json())
                    .then(result => {
                        if (result.d === "OK") {
                            listElem.remove();
                        } else {
                            alert("Errore eliminazione: " + result.d);
                        }
                    })
                    .catch(err => alert("Errore comunicazione: " + err));
            } else {
                // solo in frontend (lista non ancora salvata)
                listElem.remove();
            }
        }

        function addRow(listId) {
            const row = document.createElement('div');
            row.className = 'priority-row';
            document.getElementById(listId).appendChild(row);

            new Sortable(row, {
                group: 'shared',
                animation: 150,
                sort: true,
                onAdd: evt => {
                    const clone = evt.item.cloneNode(true);
                    evt.item.remove();
                    clone.querySelectorAll('.delete-btn').forEach(btn => btn.remove());

                    const delBtn = document.createElement('span');
                    delBtn.textContent = 'X';
                    delBtn.className = 'delete-btn';
                    delBtn.onclick = () => {
                        line.remove();
                        updateRow(row);
                    };

                    const corrId = clone.getAttribute('data-id');
                    const corrName = clone.textContent.trim().split('(')[0].replace(/^[0-9]+\s*-\s*/, ''); // rimuove eventuale id già presente
                    const value = clone.querySelector('span')?.textContent || '';
                    clone.textContent = `${corrId} - ${corrName} ${value}`;

                    clone.appendChild(delBtn);

                    const line = document.createElement('div');
                    line.className = 'row-line';
                    line.appendChild(clone);
                    row.appendChild(line);

                    updateRow(row);
                },
                onUpdate: () => updateRow(row),
                onRemove: () => updateRow(row)
            });
        }

        function updateRow(row) {
            const lines = row.querySelectorAll('.row-line');
            lines.forEach((line, index) => {
                const existingSelect = line.querySelector('.connector-select');
                let oldValue = existingSelect?.value ?? 'AND'; // salva valore attuale

                if (existingSelect) existingSelect.remove();

                if (index < lines.length - 1) {
                    const connector = document.createElement('select');
                    connector.className = 'connector-select';
                    connector.innerHTML = `
                <option value="AND">AND</option>
                <option value="OR">OR</option>
            `;
                    connector.value = oldValue; // ripristina valore precedente
                    line.appendChild(connector);
                }
            });
        }

        new Sortable(document.getElementById('allItems'), {
            group: {
                name: 'shared',
                pull: 'clone',
                put: false
            },
            animation: 150,
            sort: false
        });

        function saveSingleList(button) {
            const listContainer = button.closest('.priority-list');
            const title = listContainer.querySelector('.editable-title')?.textContent.trim() || "Senza nome";
            const rows = listContainer.querySelectorAll('.priority-row');

            const listIdAttr = listContainer.getAttribute('data-listid');
            const listId = listIdAttr ? parseInt(listIdAttr) : null;

            const toggle = listContainer.querySelector('.list-status-toggle');
            const isActive = toggle?.checked ?? true;

            const listData = {
                ListId: listId,
                ListName: title,
                IsActive: isActive,
                Rows: []
            };

            rows.forEach((row, rowIndex) => {
                const rowData = {
                    Order: rowIndex + 1,
                    Corrections: []
                };
                row.querySelectorAll('.row-line').forEach((line, lineIndex) => {
                    const correction = line.querySelector('.item');
                    if (!correction) return;

                    const corrId = correction.getAttribute('data-id');
                    const connector = line.querySelector('select')?.value ?? null;

                    rowData.Corrections.push({
                        CorrectionId: parseInt(corrId),
                        Position: lineIndex + 1,
                        ConnectorToNext: connector
                    });
                });
                listData.Rows.push(rowData);
            });

            // Invio AJAX al server
            fetch('CorrectionsPriorityLists.aspx/SaveList', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ json: JSON.stringify(listData) })
            })
                .then(response => response.json())
                .then(result => {
                    if (result.d === "OK") {
                        alert("Lista salvata con successo");
                    } else {
                        alert("Errore: " + result.d);
                    }
                })
                .catch(error => {
                    alert("Errore comunicazione: " + error);
                });
        }

        function updateListStatus(input) {

            event?.stopPropagation();  // ✅ blocca bubbling verso list-title

            const list = input.closest('.priority-list');
            const label = input.closest('label').querySelector('.status-label');

            if (input.checked) {
                list.classList.remove('inactive');
                list.classList.add('active');
                label.textContent = 'Attiva';
            } else {
                list.classList.remove('active');
                list.classList.add('inactive');
                label.textContent = 'Disattiva';
            }
        }

        function formatCorrectionDisplay(corrId, name, value) {
            const color = value > 0 ? 'green' : (value < 0 ? 'red' : 'black');
            const prefix = value > 0 ? '+' : '';
            return `<strong>${corrId}</strong> - ${name} <span style="color:${color}; font-weight:bold;">(${prefix}${value})</span>`;
        }


        window.onload = async () => {
            await loadCorrections();     // carica correzioni e aspetta
            loadSavedLists();            // poi carica le liste
        };
    </script>

</asp:Content>
