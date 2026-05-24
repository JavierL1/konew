export class DrawingBoard {
    constructor(canvas, options = {}) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');

        // Tools Configuration
        this.penWidth = options.penWidth || 3;
        this.eraserWidth = options.eraserWidth || 20;
        this.currentColor = '#000000';
        this.currentWidth = this.penWidth;

        this.drawing = false;
        this.startCoords = null;
        this.undoStack = [];
        this.maxHistory = 20;

        // Vectors / Strokes Tracking (For LiveView Engine)
        this.strokesLog = [];
        this.currentStrokePoints = [];

        // Initialize Canvas Options
        this.ctx.lineJoin = 'round';
        this.ctx.lineCap = 'round';

        this.initDrawingListeners();
        this.saveState(); // Base blank state
    }

    getCoords(e) {
        const rect = this.canvas.getBoundingClientRect();
        const scaleX = this.canvas.width / rect.width;
        const scaleY = this.canvas.height / rect.height;

        const touch = (e.touches && e.touches[0]) || (e.changedTouches && e.changedTouches[0]);
        const clientX = touch ? touch.clientX : e.clientX;
        const clientY = touch ? touch.clientY : e.clientY;

        return {
            x: Math.round((clientX - rect.left) * scaleX),
            y: Math.round((clientY - rect.top) * scaleY)
        };
    }

    initDrawingListeners() {
        const startDrawing = (e) => {
            this.drawing = true;
            this.startCoords = this.getCoords(e);

            this.ctx.beginPath();
            this.ctx.strokeStyle = this.currentColor;
            this.ctx.lineWidth = this.currentWidth;
            this.ctx.moveTo(this.startCoords.x, this.startCoords.y);

            this.currentStrokePoints = [{ x: this.startCoords.x, y: this.startCoords.y }];
        };

        const draw = (e) => {
            if (!this.drawing) return;
            const coords = this.getCoords(e);

            this.ctx.lineTo(coords.x, coords.y);
            this.ctx.stroke();

            this.currentStrokePoints.push({ x: coords.x, y: coords.y });
        };

        const stopDrawing = (e) => {
            if (!this.drawing) return;
            const endCoords = this.getCoords(e);

            if (this.isClick(this.startCoords, endCoords)) {
                this.ctx.lineTo(endCoords.x + 0.1, endCoords.y + 0.1);
                this.ctx.stroke();
                this.currentStrokePoints.push({ x: endCoords.x, y: endCoords.y });
            }

            this.ctx.closePath();
            this.drawing = false;
            this.startCoords = null;
            this.saveState();

            this.strokesLog.push({
                color: this.currentColor,
                width: this.currentWidth,
                points: this.currentStrokePoints
            });
            this.currentStrokePoints = [];
        };

        // Mouse Listeners
        this.canvas.addEventListener('mousedown', startDrawing);
        this.canvas.addEventListener('mousemove', draw);
        window.addEventListener('mouseup', stopDrawing);

        // Touch Listeners
        this.canvas.addEventListener('touchstart', (e) => { e.preventDefault(); startDrawing(e); }, { passive: false });
        this.canvas.addEventListener('touchmove', (e) => { e.preventDefault(); draw(e); }, { passive: false });
        this.canvas.addEventListener('touchend', (e) => { e.preventDefault(); stopDrawing(e); }, { passive: false });
    }

    isClick(start, end) {
        if (!start || !end) return false;
        return Math.sqrt(Math.pow(end.x - start.x, 2) + Math.pow(end.y - start.y, 2)) < 3;
    }

    saveState() {
        if (this.undoStack.length >= this.maxHistory) this.undoStack.shift();
        this.undoStack.push(this.canvas.toDataURL());
    }

    // --- API Utilities ---
    setPen() {
        this.currentColor = '#000000';
        this.currentWidth = this.penWidth;
    }

    setEraser() {
        this.currentColor = '#ffffff';
        this.currentWidth = this.eraserWidth;
    }

    clear() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        this.strokesLog = [];
        this.saveState();
    }

    undo() {
        if (this.undoStack.length <= 1) {
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
            if (this.undoStack.length === 1) this.undoStack.pop();
            this.strokesLog = [];
            return;
        }
        this.undoStack.pop();
        this.strokesLog.pop();
        const img = new Image();
        img.src = this.undoStack[this.undoStack.length - 1];
        img.onload = () => {
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
            this.ctx.drawImage(img, 0, 0);
        };
    }

    getDataUri() {
        return this.canvas.toDataURL("image/png");
    }

    getStrokes() {
        return this.strokesLog;
    }
}
